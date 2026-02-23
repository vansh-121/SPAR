@extends($activeTemplate . 'layouts.master')

@section('content')
    <div class="row justify-content-center">
        @include($activeTemplate.'partials.invest_history',['invests'=>$invests])
        @if ($invests->hasPages())
            {{ paginateLinks($invests) }}
        @endif
    </div>
@endsection