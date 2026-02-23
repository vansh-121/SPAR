@extends($activeTemplate . 'layouts.master')

@section('content')
    <div class="row justify-content-center gy-5">
        <div class="col-md-12">
            <div class="text-end">
                <a href="{{ route('user.pool.invests') }}" class="btn btn--base btn--lg">
                    @lang('My Pools')
                </a>
            </div>
        </div>

        @include($activeTemplate . 'partials.pool', ['pools' => $pools])
    </div>
@endsection
