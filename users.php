<?php
ini_set('display_errors', 1);
error_reporting(E_ALL);

header('Content-Type: application/json; charset=UTF-8');

// Prevent session issues on some hosts
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

require_once __DIR__ . '/config.php';

// config.php must define $pdo as the validated PDO connection.
if (!isset($pdo) || !$pdo instanceof PDO) {
    http_response_code(500);
    echo json_encode(['status' => 'error', 'message' => 'Database connection not initialized.']);
    exit;
}

// JSON POST bodies do NOT populate $_POST / $_REQUEST — read once and route by action.
$parsedJson = null;
$contentType = $_SERVER['CONTENT_TYPE'] ?? '';
if (
    ($_SERVER['REQUEST_METHOD'] ?? '') === 'POST'
    && stripos($contentType, 'application/json') !== false
) {
    $raw = file_get_contents('php://input');
    $parsedJson = json_decode($raw, true);
}

if (is_array($parsedJson) && isset($parsedJson['action'])) {
    $action = $parsedJson['action'];
} else {
    $action = $_REQUEST['action'] ?? 'list';
}

if ($action === 'list') {
    try {
        $sql = "SELECT u.user_id, u.full_name, u.email, u.mobile_number, u.status, u.role_id, u.barangay_id,
                       b.barangay_name, r.role_name
                FROM users u
                LEFT JOIN barangays b ON u.barangay_id = b.barangay_id
                LEFT JOIN roles r ON u.role_id = r.role_id
                WHERE u.status = 'active'";

        $stmt = $pdo->prepare($sql);
        $stmt->execute();
        $users = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo json_encode(['status' => 'success', 'message' => 'Users loaded', 'data' => $users]);
    } catch (\PDOException $e) {
        http_response_code(500);
        echo json_encode(['status' => 'error', 'message' => 'Query failed: ' . $e->getMessage()]);
    }
    exit;
}

if ($action === 'login') {
    $response = [
        'success' => false,
        'message' => '',
        'status'  => 'error',
        'data'    => null,
    ];

    $input = is_array($parsedJson) ? $parsedJson : $_POST;

    if (!is_array($input) || !isset($input['password'])) {
        http_response_code(400);
        $response['message'] = 'Identifier and password are required.';
        echo json_encode($response);
        exit;
    }

    $identifier = trim($input['identifier'] ?? $input['seniorID'] ?? '');
    $password   = trim($input['password'] ?? '');

    if ($identifier === '' || $password === '') {
        http_response_code(400);
        $response['message'] = 'Identifier and password are required.';
        echo json_encode($response);
        exit;
    }

    try {
        $sql = "SELECT u.user_id, u.full_name, u.email, u.mobile_number, u.password_hash,
                       u.is_verified, u.status, u.role_id, u.barangay_id,
                       b.barangay_name, r.role_name
                FROM users u
                LEFT JOIN barangays b ON u.barangay_id = b.barangay_id
                LEFT JOIN roles r ON u.role_id = r.role_id
                WHERE (u.email = :email OR u.mobile_number = :mobile)
                  AND u.status = 'active'
                LIMIT 1";

        $stmt = $pdo->prepare($sql);
        $stmt->execute(['email' => $identifier, 'mobile' => $identifier]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$user) {
            http_response_code(401);
            $response['message'] = 'Invalid credentials.';
            echo json_encode($response);
            exit;
        }

        if (!password_verify($password, $user['password_hash'])) {
            http_response_code(401);
            $response['message'] = 'Invalid credentials.';
            echo json_encode($response);
            exit;
        }

        $update = $pdo->prepare('UPDATE users SET last_login = NOW() WHERE user_id = :user_id');
        $update->execute(['user_id' => $user['user_id']]);

        unset($user['password_hash']);

        $response['success']     = true;
        $response['status']      = 'success';
        $response['message']     = 'User validated successfully.';
        $response['data']        = $user;
        $response['name']        = $user['full_name'];
        $response['is_verified'] = (bool) ($user['is_verified'] ?? false);
        echo json_encode($response);

    } catch (\PDOException $e) {
        http_response_code(500);
        $response['message'] = 'Query failed: ' . $e->getMessage();
        echo json_encode($response);
    }
    exit;
}

http_response_code(400);
echo json_encode(['status' => 'error', 'message' => 'Unknown action']);
exit;