# SehatMok Mobile API

This document describes the current Next.js App Router API routes that the SehatMok mobile app can use as its backend. Examples use JSON unless a route explicitly says otherwise.

Admin routes under `/api/admin/*` are not documented here because they are intended for the web admin panel and use cookie-based admin role checks.

## Base URL

Use the deployed web origin in production:

```text
https://<deployed-domain>
```

For local testing from a physical mobile device, use your laptop or development machine IP address:

```text
http://<laptop-ip>:3000
```

Do not use `localhost` on a physical device. On a phone, `localhost` means the phone itself, not your laptop. Make sure the phone and laptop are on the same network and that the firewall allows access to port `3000`.

## CORS Note

CORS has not been added yet. Native mobile apps usually can call the API directly without browser CORS restrictions. If the mobile app later uses WebView or browser-based cross-origin requests, CORS headers may need to be added to the API.

## Authentication

Mobile clients should use bearer token authentication after login or registration:

```http
Authorization: Bearer <token>
Content-Type: application/json
Accept: application/json
```

Login and registration return a JWT token in the JSON response. Store it securely on the device and send it on protected requests.

The web app still uses the HTTP-only `sehatmok_token` cookie. Mobile clients should use `Authorization: Bearer <token>` instead of cookie auth.

JWT payload:

```json
{
  "sub": "user_id"
}
```

## Common Errors

Common status codes:

- `400`: invalid request body or query
- `401`: missing or invalid auth
- `403`: inactive, suspended, or forbidden user
- `404`: resource not found
- `409`: conflict, usually duplicate data
- `500`: server error
- `502`: external AI generation failure

Typical error body:

```json
{
  "message": "Invalid profile payload.",
  "errors": {
    "fieldErrors": {},
    "formErrors": []
  }
}
```

Some profile validation responses return flattened errors at the top level:

```json
{
  "message": "Invalid profile payload.",
  "fieldErrors": {
    "age": ["Number must be greater than or equal to 10"]
  },
  "formErrors": []
}
```

## Auth Endpoints

### POST `/api/auth/login`

Auth required: No

Request body:

```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

Response example:

```json
{
  "message": "Login successful.",
  "token": "<jwt_token>",
  "user": {
    "id": "user_id",
    "email": "user@example.com",
    "name": "User Name",
    "avatarUrl": "/uploads/avatars/avatar.jpg",
    "role": "USER"
  }
}
```

Notes for mobile:

- Store `token` securely and send it as `Authorization: Bearer <token>`.
- `role` can be `USER` or `ADMIN`.
- `name` and `avatarUrl` can be `null`.
- The response also sets a web cookie for browser compatibility.
- Inactive or suspended users receive `403`.

### POST `/api/auth/register`

Auth required: No

Request body:

```json
{
  "email": "new-user@example.com",
  "password": "password123"
}
```

Response example:

```json
{
  "message": "Registration successful.",
  "token": "<jwt_token>",
  "user": {
    "id": "user_id",
    "email": "new-user@example.com",
    "name": null,
    "avatarUrl": null,
    "role": "USER"
  }
}
```

Notes for mobile:

- Password must be at least 8 characters.
- Duplicate email returns `409`.
- The response also sets a web cookie for browser compatibility.

### POST `/api/auth/logout`

Auth required: No

Request body: None

Response example:

```json
{
  "message": "Logout successful."
}
```

Notes for mobile:

- This route clears the web cookie.
- Mobile clients should delete the stored token locally.
- There is no server-side token revocation in the current implementation.

## Profile Endpoints

### GET `/api/profile`

Auth required: Yes

Request body: None

Response example:

```json
{
  "id": "user_id",
  "email": "user@example.com",
  "name": "User Name",
  "avatarUrl": "/uploads/avatars/avatar.jpg",
  "age": 27,
  "weight": 72,
  "height": 176,
  "activityLevel": "MODERATE",
  "targetCalories": 2100,
  "bmr": 1690,
  "tdee": 2620
}
```

Notes for mobile:

- `activityLevel` values are `SEDENTARY`, `LIGHT`, `MODERATE`, `ACTIVE`, and `VERY_ACTIVE`.
- Numeric profile fields can be `null`.
- `bmr` and `tdee` are calculated by the API when enough body metric data exists.

### PUT `/api/profile`

Auth required: Yes

Request body:

```json
{
  "name": "User Name",
  "avatarUrl": "/uploads/avatars/avatar.jpg",
  "age": 27,
  "weight": 72,
  "height": 176,
  "activityLevel": "MODERATE",
  "targetCalories": 2100
}
```

Response example:

```json
{
  "id": "user_id",
  "email": "user@example.com",
  "name": "User Name",
  "avatarUrl": "/uploads/avatars/avatar.jpg",
  "age": 27,
  "weight": 72,
  "height": 176,
  "activityLevel": "MODERATE",
  "targetCalories": 2100,
  "bmr": 1690,
  "tdee": 2620
}
```

Notes for mobile:

- Send at least one field.
- `name` and `avatarUrl` can be sent as empty strings to clear them.
- Updating body metrics can recalculate `targetCalories` if no explicit target is sent.
- `avatarUrl` must be a valid `http/https` URL or an uploaded avatar path.

### PATCH `/api/profile`

Auth required: Yes

Request body: Same as `PUT /api/profile`

Response example: Same as `PUT /api/profile`

Notes for mobile:

- This route currently calls the same implementation as `PUT /api/profile`.

### POST `/api/profile/avatar`

Auth required: Yes

Request body: Multipart form data

```text
avatar=<image file>
```

Response example:

```json
{
  "avatarUrl": "/uploads/avatars/avatar-1779018214033-example.jpg"
}
```

Notes for mobile:

- Use multipart upload, not JSON.
- Field name must be `avatar`.
- Accepted image types: PNG, JPG/JPEG, GIF, WebP.
- Max file size is 2 MB.
- Save the returned `avatarUrl` through `PUT` or `PATCH /api/profile`.

## Dashboard Endpoint

### GET `/api/dashboard/summary`

Auth required: Yes

Request body: None

Response example:

```json
{
  "targetCalories": 2100,
  "totalIntakeToday": 750,
  "totalOuttakeToday": 200,
  "remainingCalories": 1550,
  "macroTargets": {
    "proteinG": 158,
    "carbsG": 236,
    "fatsG": 58
  },
  "macroCurrent": {
    "proteinG": 35,
    "carbsG": 55,
    "fatsG": 14
  },
  "caloriesCurrent": 520,
  "user": {
    "name": "User Name",
    "email": "user@example.com",
    "avatarUrl": "/uploads/avatars/avatar.jpg"
  },
  "nearExpiryItems": [
    {
      "id": "fridge_item_id",
      "name": "Milk",
      "category": "Dairy",
      "quantity": 1,
      "unit": "bottle",
      "expiryDate": "2026-05-20T00:00:00.000Z",
      "expiryLabel": "Expires in 2 days"
    }
  ],
  "nearExpiryCount": 1,
  "expiredCount": 0,
  "mealPlanMissingSlots": ["Breakfast", "Dinner"],
  "fridgeItemCount": 8,
  "activeGroceryCount": 4,
  "hydration": {
    "date": "2026-05-20",
    "amountMl": 750,
    "targetMl": 2500,
    "amountLiters": 0.75,
    "targetLiters": 2.5,
    "percent": 30
  }
}
```

Notes for mobile:

- This is the recommended endpoint for a mobile home screen.
- It combines calories, macros, profile summary, fridge intelligence, grocery count, meal plan missing slots, and hydration.

## Nutrition Log Endpoints

### GET `/api/logs`

Auth required: Yes

Request body: None

Query parameters:

```text
type=INTAKE
```

Response example:

```json
[
  {
    "id": "log_id",
    "userId": "user_id",
    "type": "INTAKE",
    "calories": 500,
    "protein": null,
    "carbs": null,
    "fat": null,
    "createdAt": "2026-05-20T10:00:00.000Z"
  }
]
```

Notes for mobile:

- `type` is optional.
- Valid `type` values are `INTAKE` and `OUTTAKE`.

### POST `/api/logs`

Auth required: Yes

Request body:

```json
{
  "type": "INTAKE",
  "calories": 500
}
```

Response example:

```json
{
  "id": "log_id",
  "userId": "user_id",
  "type": "INTAKE",
  "calories": 500,
  "protein": null,
  "carbs": null,
  "fat": null,
  "createdAt": "2026-05-20T10:00:00.000Z"
}
```

Notes for mobile:

- `calories` must be a whole number from 1 to 10000.
- Current create payload only accepts `type` and `calories`.

## Fridge Endpoints

### GET `/api/fridge`

Auth required: Yes

Request body: None

Query parameters:

```text
status=near-expiry
```

Response example:

```json
[
  {
    "id": "fridge_item_id",
    "userId": "user_id",
    "name": "Milk",
    "category": "Dairy",
    "quantity": 1,
    "unit": "bottle",
    "expiryDate": "2026-05-20T00:00:00.000Z",
    "createdAt": "2026-05-18T10:00:00.000Z"
  }
]
```

Notes for mobile:

- Omit `status` to fetch all fridge items.
- Use `status=near-expiry` to fetch items expiring within the near-expiry window.

### POST `/api/fridge`

Auth required: Yes

Request body:

```json
{
  "name": "Milk",
  "category": "Dairy",
  "quantity": 1,
  "unit": "bottle",
  "expiryDate": "2026-05-20T00:00:00.000Z"
}
```

Response example:

```json
{
  "id": "fridge_item_id",
  "userId": "user_id",
  "name": "Milk",
  "category": "Dairy",
  "quantity": 1,
  "unit": "bottle",
  "expiryDate": "2026-05-20T00:00:00.000Z",
  "createdAt": "2026-05-18T10:00:00.000Z"
}
```

Notes for mobile:

- `quantity` must be positive.
- `expiryDate` is optional and can be `null`.
- Send ISO datetime for `expiryDate`.

### PUT `/api/fridge/[id]`

Auth required: Yes

Request body:

```json
{
  "name": "Low-fat Milk",
  "category": "Dairy",
  "quantity": 2,
  "unit": "bottles",
  "expiryDate": null
}
```

Response example:

```json
{
  "id": "fridge_item_id",
  "userId": "user_id",
  "name": "Low-fat Milk",
  "category": "Dairy",
  "quantity": 2,
  "unit": "bottles",
  "expiryDate": null,
  "createdAt": "2026-05-18T10:00:00.000Z"
}
```

Notes for mobile:

- Send at least one field.
- Users can update only their own fridge items.
- `PATCH /api/fridge/[id]` is not implemented; use `PUT`.

### DELETE `/api/fridge/[id]`

Auth required: Yes

Request body: None

Response example:

```json
{
  "message": "Fridge item deleted."
}
```

Notes for mobile:

- Users can delete only their own fridge items.

### DELETE `/api/fridge/expired`

Auth required: Yes

Request body: None

Response example:

```json
{
  "deletedCount": 3
}
```

Notes for mobile:

- Deletes all expired fridge items for the authenticated user.

## Recipe Endpoints

### GET `/api/recipes`

Auth required: Yes

Request body: None

Query parameters:

```text
q=chicken
category=proteins
```

Response example:

```json
[
  {
    "id": "recipe_id",
    "name": "Chicken Rice Bowl",
    "description": "Simple balanced meal.",
    "imageUrl": "/assets/recipes/chicken.jpg",
    "calories": 520,
    "protein": 35,
    "carbs": 55,
    "fat": 14,
    "matchedIngredientCount": 2,
    "totalRequiredIngredientCount": 5,
    "ingredientAvailabilityPercent": 40,
    "missingIngredients": ["rice", "soy sauce"]
  }
]
```

Notes for mobile:

- `q` searches recipe name and description.
- `category` supports `vegetables`, `fruits`, `proteins`, `dairy`, `grains`, and `nuts`.
- Availability fields are based on the authenticated user's fridge.

### GET `/api/recipes/[id]`

Auth required: No

Request body: None

Response example:

```json
{
  "id": "recipe_id",
  "name": "Chicken Rice Bowl",
  "description": "Simple balanced meal.",
  "imageUrl": "/assets/recipes/chicken.jpg",
  "calories": 520,
  "protein": 35,
  "carbs": 55,
  "fat": 14,
  "fiber": 6,
  "servings": null,
  "cookTimeMinutes": null,
  "ingredients": [
    {
      "name": "Chicken",
      "quantity": 150,
      "unit": "g"
    }
  ],
  "steps": ["Cook rice.", "Grill chicken."]
}
```

Notes for mobile:

- This route is currently public.
- `steps` is normalized to a string array.

## Recommendation Endpoints

### GET `/api/recommendations`

Auth required: Yes

Request body: None

Response example:

```json
{
  "targetCalories": 2100,
  "selectedFridgeItems": [
    {
      "id": "fridge_item_id",
      "name": "Milk",
      "category": "Dairy"
    }
  ],
  "dietaryPreferences": "",
  "recommendations": [
    {
      "id": "recipe_id",
      "name": "Chicken Rice Bowl",
      "imageUrl": "/assets/recipes/chicken.jpg",
      "calories": 520,
      "protein": 35,
      "carbs": 55,
      "fat": 14,
      "matchPercent": 50,
      "ingredientScore": 0.5,
      "calorieScore": 0.2476,
      "finalScore": 0.5,
      "explanation": "Matches 2/4 required ingredients from your fridge."
    }
  ]
}
```

Notes for mobile:

- Uses all current fridge items to score saved recipes.
- Returns up to 10 recommendations.

### POST `/api/recommendations`

Auth required: Yes

Request body:

```json
{
  "selectedFridgeItemIds": ["fridge_item_id_1", "fridge_item_id_2"],
  "dietaryPreferences": "High protein, no peanuts"
}
```

Response example:

```json
{
  "targetCalories": 2100,
  "selectedFridgeItems": [
    {
      "id": "fridge_item_id_1",
      "name": "Chicken",
      "category": "Proteins"
    }
  ],
  "dietaryPreferences": "High protein, no peanuts",
  "recommendations": [
    {
      "id": "recipe_id",
      "name": "Chicken Rice Bowl",
      "imageUrl": "/assets/recipes/chicken.jpg",
      "calories": 520,
      "protein": 35,
      "carbs": 55,
      "fat": 14,
      "matchPercent": 50,
      "ingredientScore": 0.5,
      "calorieScore": 0.2476,
      "finalScore": 0.399,
      "explanation": "Matches 2/4 ingredients. Calorie closeness: 25% (520 vs 2100)."
    }
  ]
}
```

Notes for mobile:

- Requires at least one selected fridge item ID.
- Useful as a fallback when AI generation is unavailable.

## AI Recipe Endpoints

### POST `/api/ai/generate-recipes`

Auth required: Yes

Request body:

```json
{
  "selectedFridgeItemIds": ["fridge_item_id_1", "fridge_item_id_2"],
  "dietaryPreferences": "High protein, no peanuts"
}
```

Response example:

```json
{
  "candidates": [
    {
      "name": "High Protein Chicken Bowl",
      "description": "A quick meal idea from your fridge.",
      "servings": 2,
      "cookTimeMinutes": 20,
      "ingredients": [
        {
          "name": "Chicken",
          "quantity": 150,
          "unit": "g"
        }
      ],
      "steps": ["Prepare ingredients.", "Cook and serve."],
      "nutrition": {
        "calories": 520,
        "protein": 35,
        "carbs": 55,
        "fat": 14,
        "fiber": 6
      },
      "matchedIngredientCount": 1,
      "totalRequiredIngredientCount": 3,
      "ingredientMatchPercent": 33,
      "missingIngredients": ["rice", "garlic"]
    }
  ]
}
```

Notes for mobile:

- Requires at least one fridge item ID.
- This route calls Gemini and can take longer than normal API calls.
- It can return `502` when AI generation fails.
- The API expects Gemini to return 3 to 5 candidates.
- A legacy single-result route exists at `POST /api/ai/generate-recipe`, but mobile should prefer this multi-candidate endpoint.

### POST `/api/ai/save-recipe`

Auth required: Yes

Request body:

```json
{
  "recipe": {
    "name": "High Protein Chicken Bowl",
    "description": "A quick meal idea from your fridge.",
    "servings": 2,
    "cookTimeMinutes": 20,
    "ingredients": [
      {
        "name": "Chicken",
        "quantity": 150,
        "unit": "g"
      }
    ],
    "steps": ["Prepare ingredients.", "Cook and serve."],
    "nutrition": {
      "calories": 520,
      "protein": 35,
      "carbs": 55,
      "fat": 14,
      "fiber": 6
    }
  }
}
```

Response example:

```json
{
  "recipeId": "recipe_id",
  "reused": false
}
```

Notes for mobile:

- Use this after the user chooses an AI-generated candidate.
- The API saves the recipe or reuses an existing duplicate-safe recipe.
- `reused: true` means the selected candidate matched an existing recipe.

## Meal Planner Endpoints

### GET `/api/meal-plans?date=YYYY-MM-DD`

Auth required: Yes

Request body: None

Response example:

```json
{
  "date": "2026-05-20",
  "items": [
    {
      "id": "meal_plan_id",
      "slot": "LUNCH",
      "recipe": {
        "id": "recipe_id",
        "name": "Chicken Rice Bowl",
        "imageUrl": "/assets/recipes/chicken.jpg",
        "calories": 520,
        "protein": 35,
        "carbs": 55,
        "fat": 14,
        "description": "Simple balanced meal.",
        "matchedIngredientCount": 2,
        "totalRequiredIngredientCount": 5,
        "ingredientAvailabilityPercent": 40,
        "missingIngredients": ["rice"]
      }
    }
  ]
}
```

Notes for mobile:

- `date` is required and must use `YYYY-MM-DD`.
- `slot` values are `BREAKFAST`, `LUNCH`, and `DINNER`.

### POST `/api/meal-plans`

Auth required: Yes

Request body:

```json
{
  "date": "2026-05-20",
  "slot": "LUNCH",
  "recipeId": "recipe_id"
}
```

Response example:

```json
{
  "id": "meal_plan_id",
  "slot": "LUNCH",
  "recipe": {
    "id": "recipe_id",
    "name": "Chicken Rice Bowl",
    "imageUrl": "/assets/recipes/chicken.jpg",
    "calories": 520,
    "protein": 35,
    "carbs": 55,
    "fat": 14,
    "description": "Simple balanced meal.",
    "matchedIngredientCount": 2,
    "totalRequiredIngredientCount": 5,
    "ingredientAvailabilityPercent": 40,
    "missingIngredients": ["rice"]
  }
}
```

Notes for mobile:

- Creates or replaces the recipe for the specified date and slot.

### DELETE `/api/meal-plans`

Auth required: Yes

Request body:

```json
{
  "date": "2026-05-20",
  "slot": "LUNCH"
}
```

Response example:

```json
{
  "date": "2026-05-20",
  "slot": "LUNCH"
}
```

Notes for mobile:

- Deletes the plan for a specific date and slot.
- Some HTTP clients make DELETE-with-body awkward. Use `DELETE /api/meal-plans/[id]` when that is easier.

### DELETE `/api/meal-plans/[id]`

Auth required: Yes

Request body: None

Response example:

```json
{
  "id": "meal_plan_id"
}
```

Notes for mobile:

- Deletes a specific meal plan item by ID.

## Bookmark Endpoints

### GET `/api/bookmarks`

Auth required: Yes

Request body: None

Response example:

```json
{
  "recipeIds": ["recipe_id"],
  "recipes": [
    {
      "id": "recipe_id",
      "name": "Chicken Rice Bowl",
      "imageUrl": "/assets/recipes/chicken.jpg",
      "calories": 520,
      "protein": 35,
      "carbs": 55,
      "fat": 14,
      "description": "Simple balanced meal."
    }
  ]
}
```

Notes for mobile:

- Recipes are returned in bookmark order.

### POST `/api/bookmarks`

Auth required: Yes

Request body:

```json
{
  "recipeId": "recipe_id"
}
```

Response example:

```json
{
  "recipeId": "recipe_id"
}
```

Notes for mobile:

- This uses upsert behavior, so saving an already-bookmarked recipe is safe.

### DELETE `/api/bookmarks/[recipeId]`

Auth required: Yes

Request body: None

Response example:

```json
{
  "recipeId": "recipe_id"
}
```

Notes for mobile:

- Removing a missing bookmark still returns the recipe ID.

## Grocery Endpoints

### GET `/api/grocery`

Auth required: Yes

Request body: None

Response example:

```json
[
  {
    "id": "grocery_item_id",
    "userId": "user_id",
    "name": "Eggs",
    "quantity": 12,
    "unit": "pcs",
    "isDone": false,
    "createdAt": "2026-05-20T10:00:00.000Z",
    "updatedAt": "2026-05-20T10:00:00.000Z"
  }
]
```

Notes for mobile:

- Items are ordered by incomplete first, then newest first.

### POST `/api/grocery`

Auth required: Yes

Request body:

```json
{
  "name": "Eggs",
  "quantity": 12,
  "unit": "pcs"
}
```

Response example:

```json
{
  "id": "grocery_item_id",
  "userId": "user_id",
  "name": "Eggs",
  "quantity": 12,
  "unit": "pcs",
  "isDone": false,
  "createdAt": "2026-05-20T10:00:00.000Z",
  "updatedAt": "2026-05-20T10:00:00.000Z"
}
```

Notes for mobile:

- `quantity` and `unit` are optional.
- Empty `quantity` or `unit` values are treated as omitted.

### PATCH `/api/grocery/[id]`

Auth required: Yes

Request body:

```json
{
  "name": "Eggs",
  "quantity": 6,
  "unit": "pcs",
  "isDone": true
}
```

Response example:

```json
{
  "id": "grocery_item_id",
  "userId": "user_id",
  "name": "Eggs",
  "quantity": 6,
  "unit": "pcs",
  "isDone": true,
  "createdAt": "2026-05-20T10:00:00.000Z",
  "updatedAt": "2026-05-20T10:15:00.000Z"
}
```

Notes for mobile:

- Send at least one field.
- Send `quantity: null` or `unit: null` to clear optional fields.

### DELETE `/api/grocery/[id]`

Auth required: Yes

Request body: None

Response example:

```json
{
  "message": "Grocery item deleted."
}
```

Notes for mobile:

- Users can delete only their own grocery items.

## Hydration Endpoints

### GET `/api/hydration`

Auth required: Yes

Request body: None

Query parameters:

```text
date=2026-05-20
```

Response example:

```json
{
  "date": "2026-05-20",
  "amountMl": 750,
  "targetMl": 2500,
  "amountLiters": 0.75,
  "targetLiters": 2.5,
  "percent": 30
}
```

Notes for mobile:

- If `date` is omitted, the API uses today's local date in `YYYY-MM-DD`.
- Missing logs return amount `0` and target `2500`.

### POST `/api/hydration`

Auth required: Yes

Request body:

```json
{
  "date": "2026-05-20",
  "deltaMl": 250,
  "amountMl": 1000,
  "targetMl": 3000
}
```

Response example:

```json
{
  "date": "2026-05-20",
  "amountMl": 1000,
  "targetMl": 3000,
  "amountLiters": 1,
  "targetLiters": 3,
  "percent": 33
}
```

Notes for mobile:

- Send `deltaMl` to add to the current amount.
- Send `amountMl` to set the exact amount.
- Send `targetMl` to update the target.
- `targetMl` is clamped from `500` through `10000`.
- `amountMl` cannot go below `0`.
- `percent` can exceed `100` if the user drinks more than the target.
