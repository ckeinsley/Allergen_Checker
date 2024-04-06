from typing import List
from sqlalchemy import create_engine, Column, Integer, String, ForeignKey
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship, sessionmaker
from app.data.database import Database
from app.data.models.allergen import Allergen
from app.data.models.checked_word import CheckedWord

# Create a declarative base class
engine = create_engine('sqlite:///app/data/database_files/allergens.sqlite', echo=False)
Base = declarative_base()

class CommonAllergen(Base):
    __tablename__ = 'common_allergens'
    id = Column(Integer, primary_key=True)
    name = Column(String, unique=True)
    # Define a one-to-many relationship with ScientificAllergen
    scientific_allergens = relationship("ScientificAllergen", back_populates="common_allergen")

class ScientificAllergen(Base):
    __tablename__ = 'scientific_allergens'
    id = Column(Integer, primary_key=True)
    name = Column(String, unique=True)
    common_allergen_id = Column(Integer, ForeignKey('common_allergens.id'))
    # Define a many-to-one relationship with CommonAllergen
    common_allergen = relationship("CommonAllergen", back_populates="scientific_allergens")

Base.metadata.create_all(engine)

class SqlLiteDatabase(Database):
   
    def check_words(self, words: List[str])  -> List[CheckedWord]:
        '''Checks for words in both common and scientific names'''
        results = []
        session = self.connect_to_db()
        for word in words:
            results.append(self.check_word(session, word))
        session.close()
        return results
    
    def check_word(self, session, word)  -> CheckedWord:
        '''Checks for word in both common and scientific names'''
        common = self.check_common_exists(session, word)
        if common:
            scientific_names = [scientific.name for scientific in common.scientific_allergens]
            return CheckedWord(checked_word=word, match=Allergen(common_name=common.name, scientific_names=scientific_names))
        
        scientific = self.check_scientific_exists_fuzzy(session, word)
        if scientific:
            common = self.check_common_exists(session, scientific.common_allergen.name)
            scientific_names = [scientific.name for scientific in common.scientific_allergens]
            return CheckedWord(checked_word=word, match=Allergen(common_name=common.name, scientific_names=scientific_names))
        return CheckedWord(checked_word=word)
    
    def get_all_allergens(self, skip, limit) -> List[Allergen]:
        session = self.connect_to_db()
        common_allergens = session.query(CommonAllergen).order_by(CommonAllergen.name).offset(skip).limit(limit).all()
        results = []
        for common_allergen in common_allergens:
            scientific_allergens = session.query(ScientificAllergen).filter(ScientificAllergen.common_allergen_id == common_allergen.id).order_by(ScientificAllergen.name).all()
            result_allergen = Allergen(common_name=common_allergen.name, scientific_names=[scientific.name for scientific in scientific_allergens])
            results.append(result_allergen)
        session.close()
        return results
    
    def get_total_number_of_allergens(self):
        session = self.connect_to_db()
        count = session.query(CommonAllergen).count()
        session.close()
        return count
    
    def add_allergens(self, allergens: List[Allergen]):
        '''Adds a allergens to the database. If the common exists already, just appened scientific to it, otherwise both are created'''
        session = self.connect_to_db()
        for allergen in allergens:
            common = self.check_common_exists(session, allergen.common_name)
            if not common:
                common = CommonAllergen(name=allergen.common_name.lower())
                session.add(common)

            for scentific_allergen in allergen.scientific_names:
                scientific = ScientificAllergen(name=scentific_allergen.lower(), common_allergen=common)
                if not self.check_scientific_exists(session, scientific.name):
                    session.add(scientific)
        session.commit()
        session.close()
    
    def delete_allergens(self, allergens: List[Allergen]):
        '''If common name, delete everything, else only remove scientific, but if last scientific is deleted, delete everything'''
        session = self.connect_to_db()
        for allergen in allergens:
            common_model = self.check_common_exists(session, allergen.common_name)
            if not common_model:
                print('Attempted to delete something that doesnt exist')
                break
            for scientific_name in allergen.scientific_names:
                scientific_model = session.query(ScientificAllergen).filter(ScientificAllergen.name==scientific_name.lower(), ScientificAllergen.common_allergen==common_model).first()
                if scientific_model:
                    session.delete(scientific_model)
            if not common_model.scientific_allergens:
                session.delete(common_model)

        session.commit()
        session.close()
                
    
    def connect_to_db(self):
        Session = sessionmaker(bind=engine)
        return Session()

    def check_common_exists(self, session, name):
        existing_common_allergen = session.query(CommonAllergen).filter_by(name=name.lower()).first()
        return existing_common_allergen

    def check_scientific_exists(self, session, name):
        existing_scientific_allergen = session.query(ScientificAllergen).filter_by(name=name.lower()).first()
        return existing_scientific_allergen

    def check_scientific_exists_fuzzy(self, session, name):
        existing_scientific_allergen = session.query(ScientificAllergen).filter(ScientificAllergen.name.like(f'%{name.lower()}%')).first()
        return existing_scientific_allergen