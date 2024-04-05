from typing import List
from pydantic import BaseModel

class Allergen(BaseModel):
    common_name: str
    scientific_names: List[str]
