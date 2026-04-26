<?php
use App\Models\User;
use App\Models\Organisation;
use App\Models\Wallet;
use App\Models\Transaction;
use App\Models\GepStat;
use Illuminate\Support\Facades\Hash;

$users = [];
$orgs = [];

// Create 5 Users
for ($i = 1; $i <= 5; $i++) {
    $userEmail = "user{$i}_" . time() . "@test.com";
    $user = User::create([
        'name' => "User {$i}",
        'prenom' => 'Test',
        'email' => $userEmail,
        'phone' => "0000000{$i}",
        'password' => Hash::make('password'),
        'role' => 'user',
        'code_qr' => "QR_USER_{$i}_" . time(),
    ]);

    // Create wallet for user
    Wallet::create([
        'owner_id' => $user->id,
        'owner_type' => User::class,
        'point_type' => 'standard',
        'balance' => 5000 + ($i * 1000)
    ]);

    $users[] = $user;
}

// Create 3 Orgs for first 3 users
for ($i = 0; $i < 3; $i++) {
    $orgEmail = "org{$i}_" . time() . "@test.com";
    $org = Organisation::create([
        'name' => "Org " . ($i + 1),
        'email' => $orgEmail,
        'phone' => "1111111{$i}",
        'address' => "Address " . ($i + 1),
        'user_id' => $users[$i]->id,
        'code_qr' => "QR_ORG_" . ($i + 1) . "_" . time(),
    ]);

    // Create wallet for organisation
    Wallet::create([
        'owner_id' => $org->id,
        'owner_type' => Organisation::class,
        'point_type' => 'standard',
        'balance' => 10000 + ($i * 2000)
    ]);

    $orgs[] = $org;
}

// Create some transactions
// User 1 to User 2
Transaction::create([
    'sender_id' => $users[0]->id,
    'sender_type' => User::class,
    'receiver_id' => $users[1]->id,
    'receiver_type' => User::class,
    'amount' => 500,
    'type' => 'transfer',
    'status' => 'completed',
    'reference' => 'TRX_' . time() . '_1'
]);

// Org 1 to User 4
Transaction::create([
    'sender_id' => $orgs[0]->id,
    'sender_type' => Organisation::class,
    'receiver_id' => $users[3]->id,
    'receiver_type' => User::class,
    'amount' => 1000,
    'type' => 'transfer',
    'status' => 'completed',
    'reference' => 'TRX_' . time() . '_2'
]);

// User 5 to Org 2
Transaction::create([
    'sender_id' => $users[4]->id,
    'sender_type' => User::class,
    'receiver_id' => $orgs[1]->id,
    'receiver_type' => Organisation::class,
    'amount' => 1500,
    'type' => 'transfer',
    'status' => 'completed',
    'reference' => 'TRX_' . time() . '_3'
]);

// Create global GepStats
GepStat::updateOrCreate(
    ['id' => 1],
    [
        'total_points_in_circulation' => 200000,
        'total_transactions_volume' => 75000,
        'active_users_count' => User::count(),
        'active_organisations_count' => Organisation::count()
    ]
);

echo "Donnees enregistrees avec succes!\n";
