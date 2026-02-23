@extends($activeTemplate . 'layouts.' . $layout)

@section('content')

    <section class="plan-section @if($layout == 'frontend') my-120 @endif">
        <div class="@if($layout == 'frontend') container @endif">
            <div class="row gy-5 justify-content-center">

                @auth
                    <div class="col-md-12">
                        <div class="text-end">
                            <a href="{{ route('user.invest.statistics') }}" class="btn btn--base btn--lg">
                                @lang('My Investments')
                            </a>
                        </div>
                    </div>
                @endauth

                @include($activeTemplate . 'partials.plan', ['plans' => $plans, 'layout' => $layout])
            </div>
        </div>
    </section>

    @guest
        @if (@$sections->secs != null)
            @foreach (json_decode($sections->secs) as $sec)
                @include($activeTemplate . 'sections.' . $sec)
            @endforeach
        @endif
    @endguest

@endsection

