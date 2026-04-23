<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

require_once 'config.php';

$action = $_GET['action'] ?? $_POST['action'] ?? '';

if ($action === 'list') {
    try {
        $user_id = $_GET['user_id'] ?? null;

        if (!$user_id) {
            echo json_encode([
                'status' => 'error',
                'message' => 'user_id is required'
            ]);
            exit;
        }

        $sql = "SELECT 
                    hr.report_id,
                    hr.title,
                    hr.description,
                    ht.name AS hazard_type,
                    rs.status_name AS current_status,
                    rs.color_code AS status_color,
                    hr.severity,
                    hr.latitude,
                    hr.longitude,
                    hr.location_text,
                    b.barangay_name,
                    u.full_name AS reporter_name,
                    hr.created_at,
                    rp.file_url AS image_url
                FROM hazard_reports hr
                JOIN hazard_types ht 
                    ON hr.hazard_type_id = ht.hazard_type_id
                JOIN report_statuses rs 
                    ON hr.current_status_id = rs.status_id
                JOIN barangays b 
                    ON hr.barangay_id = b.barangay_id
                JOIN users u 
                    ON hr.reporter_user_id = u.user_id
                LEFT JOIN report_photos rp 
                    ON hr.report_id = rp.report_id AND rp.is_primary = 1
                WHERE hr.reporter_user_id = :user_id
                ORDER BY hr.created_at DESC
                LIMIT 10";

        $stmt = $pdo->prepare($sql);
        $stmt->execute([':user_id' => $user_id]);
        $data = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo json_encode([
            'status' => 'success',
            'data' => $data
        ]);
        exit;

    } catch (\PDOException $e) {
        echo json_encode([
            'status' => 'error',
            'message' => $e->getMessage()
        ]);
        exit;
    }
}

elseif ($action === 'stats') {
    try {
        $user_id = $_GET['user_id'] ?? null;

        if (!$user_id) {
            echo json_encode([
                'status' => 'error',
                'message' => 'user_id is required'
            ]);
            exit;
        }

        $sql = "SELECT 
                    COUNT(*) AS total_reports,
                    SUM(CASE WHEN rs.status_name = 'Cleared' THEN 1 ELSE 0 END) AS verified
                FROM hazard_reports hr
                JOIN report_statuses rs 
                    ON hr.current_status_id = rs.status_id
                WHERE hr.reporter_user_id = :user_id";

        $stmt = $pdo->prepare($sql);
        $stmt->execute([':user_id' => $user_id]);
        $data = $stmt->fetch(PDO::FETCH_ASSOC);

        echo json_encode([
            'status' => 'success',
            'data' => $data
        ]);
        exit;

    } catch (\PDOException $e) {
        echo json_encode([
            'status' => 'error',
            'message' => $e->getMessage()
        ]);
        exit;
    }
}

elseif ($action === 'submit') {
    try {
        $user_id = $_POST['user_id'] ?? null;
        $barangay_id = $_POST['barangay_id'] ?? null;
        $hazard_type_id = $_POST['hazard_type_id'] ?? null;
        $title = trim($_POST['title'] ?? '');
        $description = trim($_POST['description'] ?? '');
        $latitude = $_POST['latitude'] ?? null;
        $longitude = $_POST['longitude'] ?? null;
        $location_text = trim($_POST['location_text'] ?? '');
        $severity = $_POST['severity'] ?? 'medium';

        if (!$user_id || !$barangay_id || !$hazard_type_id || $title === '') {
            echo json_encode([
                'status' => 'error',
                'message' => 'Missing required fields'
            ]);
            exit;
        }

        // Default status = Pending (status_id = 1 based on your SQL dump)
        $status_id = 1;

        $pdo->beginTransaction();

        // Insert main report first
        $sql = "INSERT INTO hazard_reports (
                    reporter_user_id,
                    barangay_id,
                    hazard_type_id,
                    current_status_id,
                    title,
                    description,
                    latitude,
                    longitude,
                    location_text,
                    severity
                ) VALUES (
                    :user_id,
                    :barangay_id,
                    :hazard_type_id,
                    :status_id,
                    :title,
                    :description,
                    :latitude,
                    :longitude,
                    :location_text,
                    :severity
                )";

        $stmt = $pdo->prepare($sql);
        $stmt->execute([
            ':user_id' => $user_id,
            ':barangay_id' => $barangay_id,
            ':hazard_type_id' => $hazard_type_id,
            ':status_id' => $status_id,
            ':title' => $title,
            ':description' => $description,
            ':latitude' => $latitude,
            ':longitude' => $longitude,
            ':location_text' => $location_text,
            ':severity' => $severity,
        ]);

        $report_id = $pdo->lastInsertId();

        // Save uploaded photo into report_photos table
        if (!empty($_FILES['image']['name'])) {
            $targetDir = "uploads/";

            if (!is_dir($targetDir)) {
                mkdir($targetDir, 0777, true);
            }

            $originalName = basename($_FILES['image']['name']);
            $fileName = time() . "_" . $originalName;
            $targetFile = $targetDir . $fileName;

            if (move_uploaded_file($_FILES['image']['tmp_name'], $targetFile)) {
                $sqlPhoto = "INSERT INTO report_photos (
                                report_id,
                                file_url,
                                file_name,
                                file_size,
                                is_primary
                             ) VALUES (
                                :report_id,
                                :file_url,
                                :file_name,
                                :file_size,
                                :is_primary
                             )";

                $stmtPhoto = $pdo->prepare($sqlPhoto);
                $stmtPhoto->execute([
                    ':report_id' => $report_id,
                    ':file_url' => $targetFile,
                    ':file_name' => $originalName,
                    ':file_size' => $_FILES['image']['size'] ?? null,
                    ':is_primary' => 1,
                ]);
            }
        }

        // Insert initial status history
        $sqlHistory = "INSERT INTO report_status_history (
                            report_id,
                            changed_by_user_id,
                            old_status_id,
                            new_status_id,
                            remarks
                       ) VALUES (
                            :report_id,
                            :changed_by_user_id,
                            NULL,
                            :new_status_id,
                            :remarks
                       )";

        $stmtHistory = $pdo->prepare($sqlHistory);
        $stmtHistory->execute([
            ':report_id' => $report_id,
            ':changed_by_user_id' => $user_id,
            ':new_status_id' => $status_id,
            ':remarks' => 'Initial report submission'
        ]);

        // Notify barangay officials / LGU / Admin in same barangay
        $sqlNotif = "INSERT INTO notifications (
                        user_id,
                        report_id,
                        title,
                        message,
                        notif_type
                     )
                     SELECT 
                        u.user_id,
                        :report_id,
                        'New Hazard Report',
                        CONCAT('New ', ht.name, ' reported in your barangay'),
                        'system'
                     FROM users u
                     JOIN hazard_types ht 
                        ON ht.hazard_type_id = :hazard_type_id
                     WHERE u.barangay_id = :barangay_id
                     AND u.role_id IN (
                        SELECT role_id 
                        FROM roles 
                        WHERE role_name IN ('Official', 'LGU', 'Admin')
                     )";

        $stmtNotif = $pdo->prepare($sqlNotif);
        $stmtNotif->execute([
            ':report_id' => $report_id,
            ':hazard_type_id' => $hazard_type_id,
            ':barangay_id' => $barangay_id,
        ]);

        $pdo->commit();

        echo json_encode([
            'status' => 'success',
            'message' => 'Report submitted successfully',
            'report_id' => $report_id
        ]);
        exit;

    } catch (\Throwable $e) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }

        echo json_encode([
            'status' => 'error',
            'message' => $e->getMessage()
        ]);
        exit;
    }
}

elseif ($action === 'list_hazardtype') {
    try {
        $stmt = $pdo->query("
            SELECT 
                hazard_type_id,
                name,
                description,
                icon_name,
                color_code,
                is_active
            FROM hazard_types
            WHERE is_active = 1
            ORDER BY name ASC
        ");

        $data = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo json_encode([
            'status' => 'success',
            'data' => $data
        ]);
        exit;

    } catch (\PDOException $e) {
        echo json_encode([
            'status' => 'error',
            'message' => $e->getMessage()
        ]);
        exit;
    }
}

elseif ($action === 'list_all') {
    try {
        $sql = "SELECT 
                    hr.report_id,
                    hr.title,
                    hr.description,
                    ht.name AS hazard_type,
                    ht.color_code AS hazard_color,
                    rs.status_name AS current_status,
                    rs.color_code AS status_color,
                    hr.severity,
                    hr.latitude,
                    hr.longitude,
                    hr.location_text,
                    b.barangay_name,
                    u.full_name AS reporter_name,
                    hr.created_at,
                    rp.file_url AS image_url
                FROM hazard_reports hr
                JOIN hazard_types ht ON hr.hazard_type_id = ht.hazard_type_id
                JOIN report_statuses rs ON hr.current_status_id = rs.status_id
                JOIN barangays b ON hr.barangay_id = b.barangay_id
                JOIN users u ON hr.reporter_user_id = u.user_id
                LEFT JOIN report_photos rp ON hr.report_id = rp.report_id AND rp.is_primary = 1
                WHERE rs.is_terminal = 0
                ORDER BY hr.created_at DESC";

        $stmt = $pdo->prepare($sql);
        $stmt->execute();
        $data = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo json_encode(['status' => 'success', 'data' => $data]);
        exit;

    } catch (\PDOException $e) {
        echo json_encode(['status' => 'error', 'message' => $e->getMessage()]);
        exit;
    }
}

else {
    echo json_encode([
        'status' => 'error',
        'message' => 'Invalid action'
    ]);
    exit;
}
?>