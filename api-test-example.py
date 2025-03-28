import unittest
import requests

class TestRecipeAPI(unittest.TestCase):
    API_URL = "http://localhost:8080/recipes"

    def test_create_and_get_recipe(self):
        # Sample recipe to create
        new_recipe = {
            "name": "Test Pancakes",
            "ingredients": ["flour", "milk", "eggs"],
            "instructions": "Mix and fry it."
        }

        # POST: Create new recipe
        post_response = requests.post(self.API_URL, json=new_recipe)
        self.assertEqual(post_response.status_code, 201)

        # GET: Fetch all recipes
        get_response = requests.get(self.API_URL)
        self.assertEqual(get_response.status_code, 200)

        # Check if our recipe is in the list
        recipes = get_response.json()
        self.assertTrue(any(r["name"] == "Test Pancakes" for r in recipes))

    def test_get_all_recipes(self):
        response = requests.get(self.API_URL)
        self.assertEqual(response.status_code, 200)
        self.assertIsInstance(response.json(), list)

if __name__ == '__main__':
    unittest.main()

