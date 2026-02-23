@php
    $planCaption = getContent('plan.content', true);
    $plans = App\Models\Plan::with('timeSetting')
        ->whereHas('timeSetting', function ($time) {
            $time->where('status', 1);
        })
        ->where('status', 1)
        ->where('featured', 1)
        ->get();
    $gatewayCurrency = null;
    if (auth()->check()) {
        $gatewayCurrency = App\Models\GatewayCurrency::whereHas('method', function ($gate) {
            $gate->where('status', 1);
        })
            ->with('method')
            ->orderby('method_code')
            ->get();
    }
@endphp

<!--============== investment plan section start here ============== -->
<section class="plan-section my-120">
    <div class="container">
        <div class="section-heading">
            <div class="section-heading__shape"></div>
            <h1 class="section-heading__title">{{ __(@$planCaption->data_values->heading) }}</h1>
            <p class="section-heading__desc">{{ __(@$planCaption->data_values->subheading) }}</p>
        </div>
        <div class="row gy-5 justify-content-center">
            @include($activeTemplate . 'partials.plan', ['plans' => $plans])
        </div>
    </div>
</section>
<!--============== investment plan section end here ============== -->
