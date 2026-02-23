@extends($activeTemplate . 'layouts.app')

@section('panel')
    <main>
        @include($activeTemplate . 'partials.header')

        @if (request()->routeIs('home'))
            @include($activeTemplate . 'partials.banner')
        @else
            @include($activeTemplate . 'partials.breadcrumb') 
        @endif
        
        @yield('content')

        @include($activeTemplate . 'partials.footer')
    </main>
@endsection
