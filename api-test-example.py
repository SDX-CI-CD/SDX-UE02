import unittest
import requests

class TestRecipeAPI(unittest.TestCase):
    API_URL = "http://localhost:8080/recipes"

    def test_create_and_get_recipe(self):
        # Sample recipe to create
        new_recipe = {
            "name": "Test Pancakes",
            "description": "Fluffy and delicious.",
            "ingredients": ["flour", "milk", "eggs"]
        }

        # POST: Create new recipe
        post_response = requests.post(self.API_URL, json=new_recipe)
        self.assertEqual(post_response.status_code, 201, f"Expected 201, got {post_response.status_code}")
        created_recipe = post_response.json()
        self.assertEqual(created_recipe["name"], new_recipe["name"])

        # GET: Fetch all recipes
        get_response = requests.get(self.API_URL)
        self.assertEqual(get_response.status_code, 200)
        recipes = get_response.json()

        # Check if our recipe is in the list
        self.assertTrue(
            any(r["name"] == new_recipe["name"] for r in recipes),
            "Created recipe not found in recipe list."
        )

    def test_get_all_recipes(self):
        response = requests.get(self.API_URL)
        self.assertEqual(response.status_code, 200)
        self.assertIsInstance(response.json(), list)

if __name__ == '__main__':
    unittest.main()
