@extends($activeTemplate . 'layouts.app')

@section('panel')
    <div class="dashboard position-relative">
        <div class="dashboard__inner flex-wrap">

            @include($activeTemplate . 'partials.user_sidebar')

            <div class="dashboard__right">

                @include($activeTemplate . 'partials.user_header')
                @include($activeTemplate . 'partials.user_breadcrumb')

                <div class="container-fluid p-0">
                    <div class="dashboard-body">
                        @yield('content')
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection
