<?php

use Carbon\Carbon;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        $now = Carbon::now();

        DB::table('notification_templates')->updateOrInsert(
            ['act' => 'AGREEMENT_DOCUMENT'],
            [
                'act'              => 'AGREEMENT_DOCUMENT',
                'name'             => 'Agreement Document',
                'subject'          => 'SPAR Debenture Subscription Agreement - Action Required',
                'push_title'       => 'Agreement Document',
                'email_body'       => '<p>Dear {{fullname}},</p><p>Congratulations on your KYC approval!</p><p>Please find attached the SPAR Debenture Subscription Agreement. Kindly review, sign, and return the document at your earliest convenience.</p><p>If you have any questions or need assistance, please don\'t hesitate to contact our support team.</p><p>Best regards,<br>{{site_name}} Team</p>',
                'sms_body'         => 'Dear {{fullname}}, Please check your email for the SPAR Debenture Subscription Agreement that requires your signature.',
                'push_body'        => 'Agreement document sent to your email. Please review and sign.',
                'shortcodes'       => json_encode([
                    'fullname'   => 'Full name of the user',
                    'username'   => 'Username of the user',
                    'site_name'  => 'Name of the site',
                ]),
                'email_status'     => 1,
                'sms_status'       => 0,
                'push_status'      => 0,
                'firebase_status'  => 0,
                'firebase_body'    => null,
                'created_at'       => $now,
                'updated_at'       => $now,
            ]
        );
    }

    public function down(): void
    {
        DB::table('notification_templates')
            ->where('act', 'AGREEMENT_DOCUMENT')
            ->delete();
    }
};
