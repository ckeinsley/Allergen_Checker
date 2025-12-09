from typing import List
from app.data.models.allergen import Allergen
from abc import ABC, abstractmethod

from app.data.models.checked_word import CheckedWord


class Database(ABC):
    @abstractmethod
    def check_words(self, words: List[str]) -> List[CheckedWord]:
        '''Checks for word in both common and scientific names'''
        pass
    
    @abstractmethod
    def add_allergens(self, allergens: List[Allergen]):
        '''Adds an allergen to the database. If the common exists already, just appened scientific to it, otherwise both are created'''
        pass
    
    @abstractmethod
    def delete_allergens(self, allergens: List[Allergen]):
        '''If common name, delete everything, else only remove scientific, but if last scientific is deleted, delete everything'''
        pass
    
    @abstractmethod
    def get_all_allergens(self, skip, limit):
        pass
    
    @abstractmethod
    def get_total_number_of_allergens(self):
        pass
    
    @abstractmethod
    def connect_to_db(self):
        pass
    
    @abstractmethod
    def check_common_exists(self, session, name):
        pass
    
    @abstractmethod
    def check_scientific_exists(self, session, name):
        pass
