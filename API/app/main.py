from typing import List

from fastapi import FastAPI, APIRouter
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import RedirectResponse, JSONResponse

from app.data.database import Database
from app.data.models.allergen import Allergen
from app.data.models.checked_word import CheckedWord
from app.data.sqlite_database import SqlLiteDatabase
from pydantic import BaseModel, Field

app = FastAPI()
router = APIRouter(prefix="/db")
app.include_router(router)
db: Database = SqlLiteDatabase()

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

@app.get("/", include_in_schema=False)
async def root():
    return RedirectResponse("/db/docs", status_code=301)

@app.get("/test")
def test_method():
    '''
    This method is for me to test particular things easily without touching other stuff
    '''
    return db.check_common_exists('What is up')

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

@app.post("/check/words", response_model=ProcessedIngredientsResponse, tags=['Processing'])
def check_ingredients(ingredients_request: IngredientsRequest):
    '''
    Given a list of ingredients to check, returns a list of matched allergens
    '''
    print("Received request body:", ingredients_request)
    checked = db.check_words(ingredients_request.ingredients)
    response = ProcessedIngredientsResponse(checked=checked, count=len(checked))
    return response

# Direct Database Integrations
class AllergenAddRequest(BaseModel):
    allergens: List[Allergen]
    
class AllergenResponse(BaseModel):
    allergens: List[Allergen]
    total: int
    
class MessageResponse(BaseModel):
    message: str

@app.post('/database', response_model=MessageResponse, tags=['Database'], status_code=202)
def add_allergen(allergenAddRequest: AllergenAddRequest):
    '''
    Add Allergens to the Database
    '''
    try:
        db.add_allergens(allergenAddRequest.allergens)
        return JSONResponse(MessageResponse(message="Successful").model_dump(), 202)
    except Exception as e:
        print(e)
        return JSONResponse(MessageResponse(message=f"Something went wrong").model_dump(), 500)

@app.delete('/database', response_model=MessageResponse, tags=['Database'])
def delete_allergens(allergenAddRequest: AllergenAddRequest):
    '''
    Delete Allergens from the Database
    '''
    try:
        db.delete_allergens(allergenAddRequest.allergens)
        return JSONResponse(MessageResponse(message="Successful").model_dump(), 202)
    except Exception as e:
        print(e)
        return JSONResponse(MessageResponse(message=f"Something went wrong").model_dump(), 500)

@app.get('/database', response_model=AllergenResponse, tags=['Database'])
def get_allergens(skip: int = 0, limit: int = 10):
    '''
    Returns list of allergens
    '''
    try:
        allergens = db.get_all_allergens(skip, limit)
        count = db.get_total_number_of_allergens()
        return AllergenResponse(allergens=allergens, total=count)
    except Exception as e:
        return JSONResponse(MessageResponse(message=f"Something went wrong").model_dump(), 500)
