from typing import List
from app.ai.models.ai_checked_word import AICheckedWord
from abc import ABC, abstractmethod


class AIChecker(ABC):
    @abstractmethod
    def check_allergens(self, allergens: List[str], ingredients: List[str]) -> List[AICheckedWord]:
        '''Uses AI to check if any ingredients are in the list of allergens'''
        pass
