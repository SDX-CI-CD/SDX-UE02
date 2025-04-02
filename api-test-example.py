import unittest
import requests


class TestRecipeAPI(unittest.TestCase):
    BASE_URL = "http://localhost:8080/recipes"

    def test_create_and_get_recipe(self):
        new_recipe = {
            "name": "Test Pancakes",
            "description": "Fluffy and delicious",
            "ingredients": ["flour", "milk", "eggs"]
        }

        # Create the recipe
        response_post = requests.post(self.BASE_URL, json=new_recipe)
        self.assertIn(
            response_post.status_code, [200, 201],
            f"Expected 200 or 201, got {response_post.status_code}"
        )

        # Get all recipes
        response_get = requests.get(self.BASE_URL)
        self.assertEqual(response_get.status_code, 200)

        # Verify created recipe is in the list
        recipes = response_get.json()
        self.assertTrue(
            any(recipe.get("name") == "Test Pancakes" for recipe in recipes),
            "Created recipe not found in the recipe list"
        )

    def test_get_all_recipes(self):
        response = requests.get(self.BASE_URL)
        self.assertEqual(response.status_code, 200)
        self.assertIsInstance(response.json(), list)


if __name__ == '__main__':
    unittest.main()
