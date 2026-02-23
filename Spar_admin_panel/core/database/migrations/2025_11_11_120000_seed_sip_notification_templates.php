<?php

use Carbon\Carbon;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        $now = Carbon::now();

        $templates = [
            [
                'act'              => 'SIP_INSTALLMENT_DUE',
                'name'             => 'SIP Installment Due',
                'subject'          => 'Add Funds So Today’s SIP Can Run',
                'push_title'       => 'SIP Installment Due',
                'email_body'       => '<p>Hi {{fullname}},</p><p>Your scheduled SIP installment of {{amount}} {{site_currency}} for {{plan_name}} is due today, but your deposit wallet currently has {{current_balance}} {{site_currency}}. Please add funds so your investment keeps growing.</p><p>Next deduction attempt: {{next_invest}}</p>',
                'sms_body'         => 'SIP due today for {{plan_name}}. Add {{amount}} {{site_currency}} now so your plan keeps growing.',
                'push_body'        => 'SIP due for {{plan_name}}. Add funds now to complete today’s installment.',
                'shortcodes'       => json_encode([
                    'fullname'         => 'Full name of the user',
                    'amount'           => 'Installment amount',
                    'plan_name'        => 'Plan name',
                    'current_balance'  => 'Current deposit wallet balance',
                    'next_invest'      => 'Timestamp of the next scheduled attempt',
                    'plan_id'          => 'Plan identifier',
                    'invest_id'        => 'Investment identifier',
                    'cta_text'         => 'CTA button text',
                    'cta_url'          => 'CTA deep link URL',
                ]),
                'email_status'     => 1,
                'sms_status'       => 0,
                'push_status'      => 1,
                'firebase_status'  => 0,
                'firebase_body'    => null,
                'created_at'       => $now,
                'updated_at'       => $now,
            ],
            [
                'act'              => 'SIP_INSTALLMENT_UPCOMING',
                'name'             => 'SIP Installment Upcoming',
                'subject'          => 'Reminder: SIP Installment Due Soon',
                'push_title'       => 'SIP Installment Reminder',
                'email_body'       => '<p>Hi {{fullname}},</p><p>Your SIP installment of {{amount}} {{site_currency}} for {{plan_name}} is scheduled on {{next_invest}} ({{days}} days left). Please ensure your deposit wallet has enough balance so the plan can auto-top up.</p>',
                'sms_body'         => 'Reminder: {{plan_name}} SIP of {{amount}} {{site_currency}} due in {{days}} days. Add funds to avoid a miss.',
                'push_body'        => 'Reminder: {{plan_name}} SIP due soon. Add funds to stay on track.',
                'shortcodes'       => json_encode([
                    'fullname'   => 'Full name of the user',
                    'amount'     => 'Installment amount',
                    'plan_name'  => 'Plan name',
                    'next_invest'=> 'Scheduled execution datetime',
                    'days'       => 'Days remaining',
                    'plan_id'    => 'Plan identifier',
                    'invest_id'  => 'Investment identifier',
                    'cta_text'   => 'CTA button text',
                    'cta_url'    => 'CTA deep link URL',
                ]),
                'email_status'     => 1,
                'sms_status'       => 0,
                'push_status'      => 1,
                'firebase_status'  => 0,
                'firebase_body'    => null,
                'created_at'       => $now,
                'updated_at'       => $now,
            ],
            [
                'act'              => 'SIP_INSTALLMENT_OVERDUE',
                'name'             => 'SIP Installment Overdue',
                'subject'          => 'SIP Installment Missed – Add Funds Now',
                'push_title'       => 'SIP Installment Missed',
                'email_body'       => '<p>Hi {{fullname}},</p><p>Your SIP installment of {{amount}} {{site_currency}} for {{plan_name}} was missed {{days}} day(s) ago because of low balance. Add funds now so your investment can resume.</p>',
                'sms_body'         => 'Missed SIP for {{plan_name}} ({{amount}} {{site_currency}}). Add funds so your plan can continue.',
                'push_body'        => 'Missed SIP installment for {{plan_name}}. Add funds to get back on track.',
                'shortcodes'       => json_encode([
                    'fullname'   => 'Full name of the user',
                    'amount'     => 'Installment amount',
                    'plan_name'  => 'Plan name',
                    'days'       => 'Days overdue',
                    'plan_id'    => 'Plan identifier',
                    'invest_id'  => 'Investment identifier',
                    'cta_text'   => 'CTA button text',
                    'cta_url'    => 'CTA deep link URL',
                ]),
                'email_status'     => 1,
                'sms_status'       => 0,
                'push_status'      => 1,
                'firebase_status'  => 0,
                'firebase_body'    => null,
                'created_at'       => $now,
                'updated_at'       => $now,
            ],
            [
                'act'              => 'SIP_INSTALLMENT_AUTO_COMPLETED',
                'name'             => 'SIP Installment Auto Completed',
                'subject'          => 'SIP Installment Auto-Completed Successfully',
                'push_title'       => 'SIP Auto Top-Up Successful',
                'email_body'       => '<p>Hi {{fullname}},</p><p>Great news! Your SIP installment of {{amount}} {{site_currency}} for {{plan_name}} was auto-deducted successfully. Your new deposit wallet balance is {{new_balance}} {{site_currency}}.</p>',
                'sms_body'         => 'SIP installment of {{amount}} {{site_currency}} for {{plan_name}} auto-completed successfully.',
                'push_body'        => 'SIP auto top-up successful for {{plan_name}}.',
                'shortcodes'       => json_encode([
                    'fullname'    => 'Full name of the user',
                    'amount'      => 'Installment amount',
                    'plan_name'   => 'Plan name',
                    'new_balance' => 'Updated deposit wallet balance',
                    'plan_id'     => 'Plan identifier',
                    'invest_id'   => 'Investment identifier',
                ]),
                'email_status'     => 1,
                'sms_status'       => 0,
                'push_status'      => 1,
                'firebase_status'  => 0,
                'firebase_body'    => null,
                'created_at'       => $now,
                'updated_at'       => $now,
            ],
        ];

        foreach ($templates as $template) {
            DB::table('notification_templates')->updateOrInsert(
                ['act' => $template['act']],
                $template
            );
        }
    }

    public function down(): void
    {
        DB::table('notification_templates')
            ->whereIn('act', [
                'SIP_INSTALLMENT_DUE',
                'SIP_INSTALLMENT_UPCOMING',
                'SIP_INSTALLMENT_OVERDUE',
                'SIP_INSTALLMENT_AUTO_COMPLETED',
            ])
            ->delete();
    }
};

