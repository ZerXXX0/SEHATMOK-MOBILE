USE sehatmok;

INSERT INTO users (
  id, email, password_hash, name, avatar_url, role, status,
  age, weight, height, activity_level, target_calories
) VALUES (
  'demo-user',
  'demo@example.com',
  '$2y$10$jzfKyRP1SgrwmeiEQseWDumBs0EAqCwYLsnEhDuTkRgJBC8eQAmvK',
  'Demo User',
  NULL,
  'user',
  'active',
  28,
  68.50,
  170.00,
  'moderate',
  2200
);

INSERT INTO fridge_items (
  id, user_id, name, category, quantity, unit, expiry_date, created_at
) VALUES
  ('fridge-1', 'demo-user', 'Eggs', 'protein', 12, 'pcs', DATE_ADD(NOW(), INTERVAL 5 DAY), NOW()),
  ('fridge-2', 'demo-user', 'Spinach', 'vegetables', 1, 'bag', DATE_ADD(NOW(), INTERVAL 2 DAY), NOW()),
  ('fridge-3', 'demo-user', 'Rice', 'carbs', 2, 'kg', DATE_ADD(NOW(), INTERVAL 30 DAY), NOW());

INSERT INTO recipes (
  id, name, description, image_url, ingredients, instructions,
  preparation_time, cooking_time, servings, difficulty, nutrition, created_at
) VALUES
  (
    'recipe-1',
    'Veggie Egg Scramble',
    'A quick breakfast using fridge staples.',
    NULL,
    JSON_ARRAY('Eggs', 'Spinach', 'Salt', 'Pepper'),
    JSON_ARRAY('Whisk the eggs.', 'Cook spinach briefly.', 'Scramble together and serve.'),
    10,
    8,
    2,
    'easy',
    JSON_OBJECT('calories', 320, 'protein', 19, 'carbs', 12, 'fat', 21, 'fiber', 3),
    NOW()
  ),
  (
    'recipe-2',
    'Chicken Rice Bowl',
    'A balanced lunch bowl with rice and protein.',
    NULL,
    JSON_ARRAY('Rice', 'Chicken', 'Garlic', 'Soy sauce'),
    JSON_ARRAY('Cook the rice.', 'Pan-fry the chicken.', 'Combine and season.'),
    15,
    20,
    2,
    'medium',
    JSON_OBJECT('calories', 540, 'protein', 34, 'carbs', 56, 'fat', 18, 'fiber', 4),
    NOW()
  ),
  (
    'recipe-3',
    'Simple Vegetable Soup',
    'Light soup for dinner or meal prep.',
    NULL,
    JSON_ARRAY('Carrot', 'Spinach', 'Onion', 'Broth'),
    JSON_ARRAY('Sauté onion.', 'Add vegetables and broth.', 'Simmer until tender.'),
    12,
    25,
    4,
    'easy',
    JSON_OBJECT('calories', 180, 'protein', 6, 'carbs', 22, 'fat', 7, 'fiber', 5),
    NOW()
  );
