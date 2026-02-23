<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::table('deposits', function (Blueprint $table) {
            $table->unsignedBigInteger('invest_id')->nullable()->after('plan_id');
            $table->tinyInteger('is_topup')->default(0)->after('invest_id');
            $table->tinyInteger('include_accrued_interest')->default(0)->after('is_topup');
            $table->index('invest_id');
        });
    }

    public function down(): void
    {
        Schema::table('deposits', function (Blueprint $table) {
            $table->dropIndex(['invest_id']);
            $table->dropColumn(['invest_id','is_topup','include_accrued_interest']);
        });
    }
};













