<!-- ==================== Header Start Here ==================== -->
<header class="header" id="header">
    <div class="container">
        <nav class="navbar navbar-expand-xl navbar-light">
            <a class="navbar-brand logo" href="{{ route('home') }}">
                <img src="{{ siteLogo() }}" alt="">
            </a> 
            <button class="navbar-toggler header-button" type="button" data-bs-toggle="offcanvas"
                data-bs-target="#offcanvasDarkNavbar" aria-controls="offcanvasDarkNavbar"
                aria-label="Toggle navigation">
                <span id="hiddenNav">
                    <i class="las la-bars"></i>
                </span>
            </button>
            <div class="header-main-container ms-auto">
                <div class="header-main-container__shape"></div>
                <div class="offcanvas border-0 offcanvas-end" tabindex="-1" id="offcanvasDarkNavbar">
                    <div class="offcanvas-header">
                        <a class="logo navbar-brand" href="{{ route('home') }}">
                            <img src="{{ siteLogo() }}" alt="">
                        </a>
                        <button type="button" class="btn-close" data-bs-dismiss="offcanvas" aria-label="Close">
                            <i class="las la-times"></i>
                        </button>
                    </div>
                    <div class="offcanvas-body">
                        <ul class="navbar-nav nav-menu align-items-xl-center justify-content-end w-100">
                            
                            @if (gs('multi_language'))
                                <li class="nav-item d-xl-none">
                                    @include($activeTemplate.'partials.language')
                                </li>
                            @endif

                            <li class="nav-item {{ request()->routeIs('home') ? 'active' : '' }}">
                                <a class="nav-link" aria-current="page" href="{{ route('home') }}">@lang('Home')</a>
                            </li>

                            @php
                                $pages = App\Models\Page::where('tempname', $activeTemplate)->where('is_default', 0)->get();
                            @endphp
                            @foreach ($pages as $k => $data)
                                <li class="nav-item">
                                    <a class="nav-link" href="{{ route('pages', [$data->slug]) }}">{{ __($data->name) }}</a>
                                </li>
                            @endforeach

                            <li class="nav-item {{ request()->routeIs('plan') ? 'active' : '' }}">
                                <a class="nav-link" href="{{ route('plan') }}">@lang('Plan')</a>
                            </li>
                            <li class="nav-item {{ request()->routeIs('blogs') ? 'active' : '' }}">
                                <a class="nav-link" href="{{ route('blogs') }}">@lang('Blog')</a>
                            </li>
                            <li class="nav-item {{ request()->routeIs('contact') ? 'active' : '' }}">
                                <a class="nav-link" href="{{ route('contact') }}">@lang('Contact')</a>
                            </li>

                            <li class="nav-item d-xl-none d-block">
                                <div class="btn--groups">
                                    @guest
                                        <a href="{{ route('user.login') }}" class="btn btn--md btn--base"> @lang('LOGIN') </a>
                                    @else
                                        <a href="{{ route('user.home') }}" class="btn btn--md btn--base"> @lang('DASHBOARD') </a>
                                    @endif
                                    
                                    <span class="text"> @lang('Or')</span>

                                    @guest
                                        <a href="{{ route('user.register') }}" class="btn btn--md btn--base"> @lang('REGISTER') </a>
                                    @else
                                        <a href="{{ route('user.logout') }}" class="btn btn--md btn--base"> @lang('LOGOUT') </a>
                                    @endif
                                </div>
                            </li>
                        </ul>
                    </div>
                </div>

                <div class="header-right d-none d-xl-flex">

                    @if (gs('multi_language'))
                        @include($activeTemplate.'partials.language')
                    @endif

                    <div class="btn--groups">
                        @guest
                            <a href="{{ route('user.login') }}" class="btn btn--md btn--base"> @lang('LOGIN') </a>
                        @else
                            <a href="{{ route('user.home') }}" class="btn btn--md btn--base"> @lang('DASHBOARD') </a>
                        @endif

                        <span class="text"> @lang('Or')</span>

                        @guest
                            <a href="{{ route('user.register') }}" class="btn btn--md btn--base"> @lang('REGISTER') </a>
                        @else
                            <a href="{{ route('user.logout') }}" class="btn btn--md btn--base"> @lang('LOGOUT') </a>
                        @endif
                    </div>
                </div>
            </div>
        </nav>
    </div>
</header>
<!-- ==================== Header End Here ==================== -->