<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::table('schedule_invests', function (Blueprint $table) {
            $table->tinyInteger('sip_mode')->default(0)->after('status');
            $table->tinyInteger('notify_only')->default(1)->after('sip_mode');
            $table->tinyInteger('include_interest_on_topup')->default(0)->after('notify_only');
        });
    }

    public function down(): void
    {
        Schema::table('schedule_invests', function (Blueprint $table) {
            $table->dropColumn(['sip_mode','notify_only','include_interest_on_topup']);
        });
    }
};












