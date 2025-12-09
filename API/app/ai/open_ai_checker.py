from openai import OpenAI
import json
import os
import logging
from typing import List
from app.data.models.allergen import Allergen
from app.ai.ai_checker import AIChecker
from app.ai.models.ai_checked_word import AICheckedWord

client = OpenAI(
    api_key=os.getenv('OPEN_AI_TOKEN')
)

SYSTEM_PROMPT = """
You are a helpful assistant tasked with identifying potential allergens in products such as food or makeup.
Please always provide accurate information and avoid any speculation or unsafe claims.
If you are unsure, please clearly state that you are unsure. Please err on the side of caution.
Provide responses in a structured and clear manner.
"""
class OpenAIChecker(AIChecker):
    def check_allergens(self, allergens: List[Allergen], ingredients: List[str]) -> List[AICheckedWord]:
        '''Uses AI to check if any ingredients are in the list of allergens'''
        common_names = [allergen.common_name for allergen in allergens]
        logging.debug(f'I am checking these ingredients: {ingredients}')
        
        response = self.__check_allergens(common_names, ingredients)
        # Convert the parsed data to a list of AICheckedWord objects
        
        results = []
        for word, details in response.items():
            allergen = next((allergen for allergen in allergens if allergen.common_name == details['allergen']), None)
            checked_word = AICheckedWord(
                checked_word=word,
                match=allergen,
                confidence=details['dangerous'],
                reasoning=details['reasoning']
            )
            
            results.append(checked_word)
        return results

    def __check_allergens(self, allergens: List[str], ingredients: List[str]):
        """check ingredients against openAI"""
        # Combine ingredients and allergens into a prompt
        user_prompt = (
            "For each of the following ingredients, determine if it is dangerous for someone with the "
            "listed allergens. If an ingredient is dangerous, specify which allergen it is associated "
            "with. Format the response as a JSON object with the ingredient as the key, and the value "
            "being another JSON object containing 'dangerous' (Yes/No/Unsure/Possibly) "
            "and 'allergen' (if any) and reasoning if unsure.\n\n"
            f"Ingredients: {', '.join(ingredients)}\n"
            f"Allergens: {', '.join(allergens)}\n\n"
            "Return the result as JSON."
        )
        try:
            chat_completion = client.chat.completions.create(
                model="gpt-4o-mini",
                messages=[
                    {
                        "role": "system",
                        "content": SYSTEM_PROMPT
                    },
                    {
                        "role": "user",
                        "content": user_prompt
                    }
                ]
            )
        except OpenAI.error.RateLimitError as e:
            logging.exception('Rate Limited')
            raise e
        except Exception as e:
            logging.exception('Something else happened')
            raise e

        # Extract and return the text response from the model
        # It looks like OpenAI gives us multiple choices, so we just take the first one and run with it
        # Finish Reason tells us why it returned where it did.
        # https://github.com/openai/openai-python/blob/main/src/openai/types/chat/chat_completion.py#L23
        logging.debug('OpenAI Result Received: %s', chat_completion.choices[0])
        finish_reason = chat_completion.choices[0].finish_reason

        if finish_reason != 'stop':
            # Something else caused us to not get the whole message
            logging.error('Did not get a full response: %s',
                        chat_completion.choices[0])
            raise Exception('Did not get a full response. Erroring out')
        try:
            chat_completion_content = chat_completion.choices[0].message.content

            # Remove json block designations
            if chat_completion_content.startswith('```json'):
                chat_completion_content = chat_completion_content[len(
                    '```json'):].strip()
            if chat_completion_content.endswith('```'):
                chat_completion_content = chat_completion_content[:-len(
                    '```')].strip()

            response = json.loads(chat_completion_content.strip())
            return response
        except json.JSONDecodeError as e:
            logging.error('response was %s', chat_completion_content)
            logging.exception('Json was malformed')
            raise e

