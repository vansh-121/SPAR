<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Http\Controllers\CronController;
use Illuminate\Support\Facades\Cache;

class RunCronJobs extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'cron:run {--alias= : Run specific cron by alias}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Run all scheduled cron jobs';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        // ULTRA PERFORMANCE: Global lock to prevent ANY overlapping cron execution
        $globalLockKey = 'cron_running';
        
        if (Cache::has($globalLockKey)) {
            // Don't even log, just exit silently to reduce I/O
            return 0;
        }

        try {
            // Set a VERY SHORT lock (15 seconds) since we're processing small batches
            // This ensures rapid recovery if something crashes
            Cache::put($globalLockKey, true, 15);
            
            // CRITICAL: Set strict limits to prevent runaway processes
            ini_set('memory_limit', '128M'); // Reduced from 256M
            set_time_limit(15); // Max 15 seconds (reduced from 30)
            
            $controller = new CronController();
            
            // Set the alias if provided
            if ($this->option('alias')) {
                request()->merge(['alias' => $this->option('alias')]);
            }
            
            $controller->cron();
            
            return 0;
        } catch (\Exception $e) {
            // Minimal logging to reduce I/O
            \Log::error('Cron failed: ' . $e->getMessage());
            return 1;
        } finally {
            // ALWAYS release the lock - this is CRITICAL
            Cache::forget($globalLockKey);
        }
    }
}
