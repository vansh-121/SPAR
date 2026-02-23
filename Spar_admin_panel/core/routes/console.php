<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote')->hourly();

// Schedule the cron job to run every minute
// withoutOverlapping prevents multiple instances from running simultaneously
// onOneServer ensures only one server runs the task in a multi-server setup
Schedule::command('cron:run')
    ->everyMinute()
    ->name('cron-jobs')
    ->withoutOverlapping(5) // Lock expires after 5 minutes
    ->runInBackground()
    ->onOneServer();

