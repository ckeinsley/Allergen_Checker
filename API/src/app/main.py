import base64
import logging
import logging.config
import re
from pathlib import Path
from typing import List

from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse, RedirectResponse
from pydantic import BaseModel, Field

from app.ai.ai_checker import AIChecker
from app.ai.models.ai_checked_word import AICheckedWord
from app.ai.open_ai_checker import OpenAIChecker
from app.data.database import Database
from app.data.models.allergen import Allergen
from app.data.models.checked_word import CheckedWord
from app.data.sqlite_database import SqlLiteDatabase
from app.ocr.aws_ocr import AwsOCR
from app.ocr.models.processed_image import ProcessedImage
from app.ocr.ocr import OCR

app = FastAPI(root_path='/db')
db: Database = SqlLiteDatabase()
ocr: OCR = AwsOCR()
ai: AIChecker = OpenAIChecker()

# CORS for setting it up alongside the Flutter UI
origins = [
    "https://bnuuyschecker.com",
    "*"
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
logger = logging.getLogger()
logger.setLevel(logging.INFO)


@app.get("/", include_in_schema=False)
async def root():
    return RedirectResponse("/db/docs", status_code=301)


@app.get("/test")
def test_method():
    '''
    This method is for me to test particular things easily without touching other stuff
    '''
    return "Yeah it's working"

# Processing Requests


class IngredientsRequest(BaseModel):
    ingredients: List[str] = Field(
        ["corn", "nickel"],
        description="List of ingredients to check for allergens",
        example=["corn", "nickel"]
    )


class ProcessedIngredientsResponse(BaseModel):
    checked: List[CheckedWord]
    count: int


class ImageIngredientsResponse(BaseModel):
    checked: List[CheckedWord]
    count: int
    image: str


class AICheckedIngredientsResponse(BaseModel):
    checked: List[AICheckedWord]
    count: int


class AllergenAddRequest(BaseModel):
    allergens: List[Allergen]


class AllergenResponse(BaseModel):
    allergens: List[Allergen]
    total: int


class MessageResponse(BaseModel):
    message: str


@app.post("/check/words", response_model=ProcessedIngredientsResponse, tags=['Processing'])
def check_ingredients(ingredients_request: IngredientsRequest):
    '''
    Given a list of ingredients to check, returns a list of matched allergens
    '''
    logging.info("Received request body: %s", ingredients_request)
    checked = check_words(ingredients_request.ingredients)
    response = ProcessedIngredientsResponse(
        checked=checked, count=len(checked))
    return response


@app.post("/check/image", response_model=ImageIngredientsResponse, tags=['Processing'])
async def upload_image(file: UploadFile = File(...)):
    image_bytes = await file.read()
    processedImage: ProcessedImage = ocr.check_image(image_bytes=image_bytes)
    checked = check_words(processedImage.found_words)
    return ImageIngredientsResponse(
        image=base64.b64encode(processedImage.image_bytes).decode('utf-8'),
        checked=checked,
        count=len(checked)
    )


@app.post("/ai/check/words", response_model=AICheckedIngredientsResponse, tags=['Processing'])
def check_ingredients_ai(ingredients_request: IngredientsRequest):
    '''
    Given a list of ingredients to check, consult an AI and return a list of matched
    allergens along with a Yes/No/Unsure rating.
    '''
    logging.info("Received request body: %s", ingredients_request)
    filtered_words = __filter_words(ingredients_request.ingredients)
    checked = ai.check_allergens(
        db.get_all_allergens(skip=0, limit=100), filtered_words)
    return AICheckedIngredientsResponse(checked=checked, count=len(checked))


def clean_word(word):
    return word.replace(' ', '')


def check_words(words: List[str]):
    filtered_words = __filter_words(words)
    return db.check_words(filtered_words)


def __filter_words(words):
    # Resolve banned_words.txt relative to this file so it works in dev and when installed
    banned_path = (Path(__file__).resolve().parent / 'banned_words.txt')
    banned_words = []
    if banned_path.exists():
        banned_words = banned_path.read_text(encoding='utf-8').splitlines()
    measurement_pattern = re.compile(r'\d+(g|%|cm|mm|m|km|mg|lb|oz)')

    filtered_words = [
        word.strip() for word in words
        if len(word) > 2 and
        any(char.isalpha() for char in word) and
        word not in banned_words and
        not measurement_pattern.search(word)
    ]

    return filtered_words

# Direct Database Integrations


@app.post('/database', response_model=MessageResponse, tags=['Database'], status_code=202)
def add_allergen(allergenAddRequest: AllergenAddRequest):
    '''
    Add Allergens to the Database
    '''
    try:
        db.add_allergens(allergenAddRequest.allergens)
        return JSONResponse(MessageResponse(message="Successful").model_dump(), 202)
    except Exception:
        logging.exception("Error adding allergens")
        return JSONResponse(MessageResponse(message="Something went wrong").model_dump(), 500)


@app.delete('/database', response_model=MessageResponse, tags=['Database'])
def delete_allergens(allergenAddRequest: AllergenAddRequest):
    '''
    Delete Allergens from the Database
    '''
    try:
        db.delete_allergens(allergenAddRequest.allergens)
        return JSONResponse(MessageResponse(message="Successful").model_dump(), 202)
    except Exception:
        logging.exception("Error deleting allergens")
        return JSONResponse(MessageResponse(message="Something went wrong").model_dump(), 500)


@app.get('/database', response_model=AllergenResponse, tags=['Database'])
def get_allergens(skip: int = 0, limit: int = 10):
    '''
    Returns list of allergens
    '''
    try:
        allergens = db.get_all_allergens(skip, limit)
        count = db.get_total_number_of_allergens()
        return AllergenResponse(allergens=allergens, total=count)
    except Exception:
        logging.exception("Error retrieving allergens")
        return JSONResponse(MessageResponse(message="Something went wrong").model_dump(), 500)
