from typing import Optional
from app.data.models.allergen import Allergen
from pydantic import BaseModel

class CheckedWord(BaseModel):
    checked_word: str
    match: Optional[Allergen] = None