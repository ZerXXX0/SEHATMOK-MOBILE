<?php

declare(strict_types=1);

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

require_once __DIR__ . '/db.php';

function sendJson(int $statusCode, array $payload): never
{
    http_response_code($statusCode);
    echo json_encode($payload);
    exit;
}

function readJsonBody(): array
{
    $rawBody = file_get_contents('php://input');
    $decoded = json_decode($rawBody ?: '{}', true);

    return is_array($decoded) ? $decoded : [];
}

function uuid(): string
{
    return bin2hex(random_bytes(16));
}

function authUserId(): string
{
    return 'demo-user';
}

function mapUser(array $user): array
{
    return [
        'id' => (string) $user['id'],
        'email' => $user['email'],
        'name' => $user['name'],
        'avatarUrl' => $user['avatar_url'] ?? null,
        'role' => $user['role'],
        'status' => $user['status'],
        'age' => $user['age'] !== null ? (int) $user['age'] : null,
        'weight' => $user['weight'] !== null ? (float) $user['weight'] : null,
        'height' => $user['height'] !== null ? (float) $user['height'] : null,
        'activityLevel' => $user['activity_level'] ?? null,
        'targetCalories' => $user['target_calories'] !== null ? (int) $user['target_calories'] : null,
        'createdAt' => $user['created_at'],
    ];
}

function mapFridgeItem(array $item): array
{
    return [
        'id' => (string) $item['id'],
        'userId' => (string) $item['user_id'],
        'name' => $item['name'],
        'category' => $item['category'],
        'quantity' => (float) $item['quantity'],
        'unit' => $item['unit'],
        'expiryDate' => $item['expiry_date'],
        'createdAt' => $item['created_at'],
    ];
}

function mapRecipe(array $recipe): array
{
    return [
        'id' => (string) $recipe['id'],
        'name' => $recipe['name'],
        'description' => $recipe['description'],
        'imageUrl' => $recipe['image_url'],
        'ingredients' => json_decode($recipe['ingredients'], true) ?: [],
        'instructions' => json_decode($recipe['instructions'], true) ?: [],
        'preparationTime' => $recipe['preparation_time'] !== null ? (int) $recipe['preparation_time'] : null,
        'cookingTime' => $recipe['cooking_time'] !== null ? (int) $recipe['cooking_time'] : null,
        'servings' => $recipe['servings'] !== null ? (int) $recipe['servings'] : null,
        'difficulty' => $recipe['difficulty'],
        'nutrition' => $recipe['nutrition'] !== null ? json_decode($recipe['nutrition'], true) : null,
        'createdAt' => $recipe['created_at'],
    ];
}

$uriPath = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH) ?: '/';
$scriptDir = rtrim(str_replace('\\', '/', dirname($_SERVER['SCRIPT_NAME'])), '/');
$path = '/' . ltrim(substr($uriPath, strlen($scriptDir)), '/');
$path = rtrim($path, '/');
$method = $_SERVER['REQUEST_METHOD'];

if ($path === '' || $path === '/index.php' || $path === '/health') {
    sendJson(200, [
        'success' => true,
        'message' => 'SehatMok API is running',
        'data' => [
            'status' => 'ok',
            'time' => date('c'),
        ],
    ]);
}

if ($path === '/api/auth/register' && $method === 'POST') {
    $input = readJsonBody();
    $email = trim((string) ($input['email'] ?? ''));
    $password = (string) ($input['password'] ?? '');
    $name = trim((string) ($input['name'] ?? ''));

    if ($email === '' || $password === '' || $name === '') {
        sendJson(422, [
            'success' => false,
            'message' => 'Email, password, and name are required',
        ]);
    }

    $stmt = $pdo->prepare('SELECT id FROM users WHERE email = :email LIMIT 1');
    $stmt->execute(['email' => $email]);
    if ($stmt->fetch()) {
        sendJson(409, [
            'success' => false,
            'message' => 'Email already exists',
        ]);
    }

    $userId = uuid();
    $passwordHash = password_hash($password, PASSWORD_DEFAULT);

    $insert = $pdo->prepare(<<<SQL
INSERT INTO users (
    id, email, password_hash, name, avatar_url, role, status, age,
    weight, height, activity_level, target_calories
) VALUES (
    :id, :email, :password_hash, :name, NULL, 'user', 'active', NULL,
    NULL, NULL, NULL, NULL
)
SQL);
    $insert->execute([
        'id' => $userId,
        'email' => $email,
        'password_hash' => $passwordHash,
        'name' => $name,
    ]);

    $select = $pdo->prepare('SELECT * FROM users WHERE id = :id LIMIT 1');
    $select->execute(['id' => $userId]);
    $user = $select->fetch();

    sendJson(200, [
        'success' => true,
        'message' => 'Registration successful',
        'user' => mapUser($user),
        'token' => 'demo-token-' . $userId,
    ]);
}

if ($path === '/api/auth/login' && $method === 'POST') {
    $input = readJsonBody();
    $email = trim((string) ($input['email'] ?? ''));
    $password = (string) ($input['password'] ?? '');

    $stmt = $pdo->prepare('SELECT * FROM users WHERE email = :email LIMIT 1');
    $stmt->execute(['email' => $email]);
    $user = $stmt->fetch();

    if (!$user || !password_verify($password, $user['password_hash'])) {
        sendJson(401, [
            'success' => false,
            'message' => 'Invalid credentials',
        ]);
    }

    sendJson(200, [
        'success' => true,
        'message' => 'Login successful',
        'user' => mapUser($user),
        'token' => 'demo-token-' . $user['id'],
    ]);
}

if ($path === '/api/auth/logout' && $method === 'POST') {
    sendJson(200, [
        'success' => true,
        'message' => 'Logout successful',
    ]);
}

if ($path === '/api/profile' && $method === 'GET') {
    $stmt = $pdo->prepare('SELECT * FROM users ORDER BY created_at ASC LIMIT 1');
    $stmt->execute();
    $user = $stmt->fetch();

    if (!$user) {
        sendJson(404, [
            'success' => false,
            'message' => 'Profile not found',
        ]);
    }

    sendJson(200, mapUser($user));
}

if ($path === '/api/profile' && $method === 'PUT') {
    $input = readJsonBody();
    $stmt = $pdo->prepare('SELECT * FROM users ORDER BY created_at ASC LIMIT 1');
    $stmt->execute();
    $user = $stmt->fetch();

    if (!$user) {
        sendJson(404, [
            'success' => false,
            'message' => 'Profile not found',
        ]);
    }

    $update = $pdo->prepare(<<<SQL
UPDATE users SET
    name = :name,
    age = :age,
    weight = :weight,
    height = :height,
    activity_level = :activity_level,
    target_calories = :target_calories
WHERE id = :id
SQL);

    $update->execute([
        'name' => $input['name'] ?? $user['name'],
        'age' => $input['age'] ?? $user['age'],
        'weight' => $input['weight'] ?? $user['weight'],
        'height' => $input['height'] ?? $user['height'],
        'activity_level' => $input['activityLevel'] ?? $user['activity_level'],
        'target_calories' => $input['targetCalories'] ?? $user['target_calories'],
        'id' => $user['id'],
    ]);

    $select = $pdo->prepare('SELECT * FROM users WHERE id = :id LIMIT 1');
    $select->execute(['id' => $user['id']]);

    sendJson(200, mapUser($select->fetch()));
}

if ($path === '/api/fridge' && $method === 'GET') {
    $stmt = $pdo->query('SELECT * FROM fridge_items ORDER BY created_at DESC');
    $items = array_map('mapFridgeItem', $stmt->fetchAll());

    sendJson(200, $items);
}

if ($path === '/api/fridge' && $method === 'POST') {
    $input = readJsonBody();
    $itemId = uuid();

    $insert = $pdo->prepare(<<<SQL
INSERT INTO fridge_items (id, user_id, name, category, quantity, unit, expiry_date)
VALUES (:id, :user_id, :name, :category, :quantity, :unit, :expiry_date)
SQL);
    $insert->execute([
        'id' => $itemId,
        'user_id' => authUserId(),
        'name' => (string) ($input['name'] ?? ''),
        'category' => (string) ($input['category'] ?? ''),
        'quantity' => (float) ($input['quantity'] ?? 0),
        'unit' => (string) ($input['unit'] ?? ''),
        'expiry_date' => $input['expiryDate'] ?? null,
    ]);

    $select = $pdo->prepare('SELECT * FROM fridge_items WHERE id = :id LIMIT 1');
    $select->execute(['id' => $itemId]);

    sendJson(200, mapFridgeItem($select->fetch()));
}

if (preg_match('#^/api/fridge/([^/]+)$#', $path, $matches) && in_array($method, ['PUT', 'DELETE'], true)) {
    $itemId = $matches[1];

    if ($method === 'DELETE') {
        $delete = $pdo->prepare('DELETE FROM fridge_items WHERE id = :id');
        $delete->execute(['id' => $itemId]);

        sendJson(200, [
            'success' => true,
            'message' => 'Fridge item deleted',
        ]);
    }

    $input = readJsonBody();
    $update = $pdo->prepare(<<<SQL
UPDATE fridge_items SET
    name = :name,
    category = :category,
    quantity = :quantity,
    unit = :unit,
    expiry_date = :expiry_date
WHERE id = :id
SQL);
    $update->execute([
        'name' => (string) ($input['name'] ?? ''),
        'category' => (string) ($input['category'] ?? ''),
        'quantity' => (float) ($input['quantity'] ?? 0),
        'unit' => (string) ($input['unit'] ?? ''),
        'expiry_date' => $input['expiryDate'] ?? null,
        'id' => $itemId,
    ]);

    $select = $pdo->prepare('SELECT * FROM fridge_items WHERE id = :id LIMIT 1');
    $select->execute(['id' => $itemId]);
    $item = $select->fetch();

    if (!$item) {
        sendJson(404, [
            'success' => false,
            'message' => 'Fridge item not found',
        ]);
    }

    sendJson(200, mapFridgeItem($item));
}

if ($path === '/api/recipes' && $method === 'GET') {
    $search = trim((string) ($_GET['search'] ?? ''));
    $page = max(1, (int) ($_GET['page'] ?? 1));
    $limit = max(1, min(100, (int) ($_GET['limit'] ?? 25)));
    $offset = ($page - 1) * $limit;

    if ($search !== '') {
        $stmt = $pdo->prepare('SELECT * FROM recipes WHERE name LIKE :search ORDER BY created_at DESC LIMIT :limit OFFSET :offset');
        $stmt->execute([
            'search' => '%' . $search . '%',
            'limit' => $limit,
            'offset' => $offset,
        ]);
    } else {
        $stmt = $pdo->prepare('SELECT * FROM recipes ORDER BY created_at DESC LIMIT :limit OFFSET :offset');
        $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
        $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
        $stmt->execute();
    }

    $recipes = array_map('mapRecipe', $stmt->fetchAll());

    sendJson(200, [
        'recipes' => $recipes,
        'page' => $page,
        'limit' => $limit,
        'total' => count($recipes),
    ]);
}

if (preg_match('#^/api/recipes/([^/]+)$#', $path, $matches) && $method === 'GET') {
    $stmt = $pdo->prepare('SELECT * FROM recipes WHERE id = :id LIMIT 1');
    $stmt->execute(['id' => $matches[1]]);
    $recipe = $stmt->fetch();

    if (!$recipe) {
        sendJson(404, [
            'success' => false,
            'message' => 'Recipe not found',
        ]);
    }

    sendJson(200, mapRecipe($recipe));
}

if ($path === '/api/recommendations' && $method === 'POST') {
    $stmt = $pdo->prepare('SELECT * FROM recipes ORDER BY created_at DESC LIMIT 6');
    $stmt->execute();

    sendJson(200, [
        'recommendations' => array_map('mapRecipe', $stmt->fetchAll()),
    ]);
}

if ($path === '/api/ai/generate-recipe' && $method === 'POST') {
    $input = readJsonBody();
    $ingredients = $input['ingredients'] ?? [];

    sendJson(200, [
        'id' => uuid(),
        'name' => 'Generated Recipe',
        'description' => 'Sample recipe generated from local XAMPP API',
        'imageUrl' => null,
        'ingredients' => is_array($ingredients) ? $ingredients : [],
        'instructions' => [
            'Prepare the ingredients.',
            'Cook until done.',
            'Serve warm.',
        ],
        'preparationTime' => 10,
        'cookingTime' => 20,
        'servings' => 2,
        'difficulty' => 'easy',
        'nutrition' => [
            'calories' => 320,
            'protein' => 18,
            'carbs' => 34,
            'fat' => 11,
            'fiber' => 6,
        ],
        'createdAt' => date('c'),
    ]);
}

sendJson(404, [
    'success' => false,
    'message' => 'Endpoint not found',
]);
