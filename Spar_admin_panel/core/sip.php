<?php

set_include_path(__DIR__ . PATH_SEPARATOR . get_include_path());
require __DIR__ . '/vendor/autoload.php';

$app = require __DIR__ . '/bootstrap/app.php';

/** @var Illuminate\Contracts\Console\Kernel $kernel */
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$user = App\Models\User::where('email', 'yashparasharpcdata02@gmail.com')->firstOrFail();

notify($user, 'SIP_INSTALLMENT_DUE', [
    'fullname'        => $user->fullname,
    'amount'          => '1500.00',
    'plan_name'       => 'Growth Plan',
    'current_balance' => '0.00',
    'next_invest'     => now()->format('M d, Y H:i'),
    'plan_id'         => 4,
    'invest_id'       => 64,
    'cta_text'        => 'Add Money Now',
    'cta_url'         => route('deeplink.add-money', [
        'plan_id'   => 13,
        'invest_id' => 124,
    ]),
]);