<!DOCTYPE html>
<html lang="{{ config('app.locale') }}">

<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!-- Title -->
    <title> {{ gs()->siteName(__($pageTitle)) }}</title>
    @include('partials.seo')

    <!-- Bootstrap -->
    <link href="{{ asset('assets/global/css/bootstrap.min.css') }}" rel="stylesheet">
    <!-- Fontasosome -->
    <link href="{{ asset('assets/global/css/all.min.css') }}" rel="stylesheet">
    <!-- Slick -->
    <link rel="stylesheet" href="{{ asset($activeTemplateTrue . 'css/slick.css') }}">
    <!-- line awesome -->
    <link rel="stylesheet" href="{{ asset('assets/global/css/line-awesome.min.css') }}" />
    <!-- select2 css  -->
    <link rel="stylesheet" href="{{ asset('assets/global/css/select2.min.css') }}">
    <!-- Odometer -->
    <link rel="stylesheet" href="{{ asset($activeTemplateTrue . 'css/odometer.css') }}">
    <!-- Main css -->
    <link rel="stylesheet" href="{{ asset($activeTemplateTrue . 'css/main.css') }}">

    @stack('style-lib')

    <link rel="stylesheet" href="{{ asset($activeTemplateTrue . 'css/custom.css') }}">

    @stack('style')

    <link rel="stylesheet" href="{{ asset($activeTemplateTrue . 'css/color.php') }}?color=<?php echo gs('base_color'); ?>">
</head>

@php echo loadExtension('google-analytics') @endphp

<body>
    @stack('fbComment')
    <!--==================== Preloader Start ====================-->
    <div class="preloader">
        <div class="loader-p"></div>
    </div>
    <!--==================== Preloader End ====================-->
    <!--==================== Overlay Start ====================-->
    <div class="body-overlay"></div>
    <!--==================== Overlay End ====================-->

    <!--==================== Sidebar Overlay End ====================-->
    <div class="sidebar-overlay"></div>
    <!--==================== Sidebar Overlay End ====================-->

    <!-- ==================== Scroll to Top End Here ==================== -->
    <a class="scroll-top"><i class="fas fa-angle-double-up"></i></a>
    <!-- ==================== Scroll to Top End Here ==================== -->

    @yield('panel')

    @php
        $cookie = App\Models\Frontend::where('data_keys', 'cookie.data')->first();
    @endphp
    
    @if ($cookie->data_values->status == Status::ENABLE && !\Cookie::get('gdpr_cookie'))
        <!-- cookies dark version start -->
        <div class="cookies-card text-center hide">
            <div class="cookies-card__icon bg--base">
                <i class="las la-cookie-bite"></i>
            </div>
            <p class="mt-4 cookies-card__content">{{ $cookie->data_values->short_desc }} <a href="{{ route('cookie.policy') }}" class="text--base" target="_blank">@lang('learn more')</a></p>
            <div class="cookies-card__btn mt-4">
                <a href="javascript:void(0)" class="btn btn--base btn--lg text-white w-100 policy">@lang('Allow')</a>
            </div>
        </div>
        <!-- cookies dark version end -->
    @endif

    <!-- Jquery js -->
    <script src="{{ asset('assets/global/js/jquery-3.7.1.min.js') }}"></script>
    <!-- Bootstrap Bundle Js -->
    <script src="{{ asset('assets/global/js/bootstrap.bundle.min.js') }}"></script>
    <!-- select2 js  -->
    <script src="{{ asset('assets/global/js/select2.min.js') }}"></script>
    <!-- Slick js -->
    <script src="{{ asset($activeTemplateTrue . 'js/slick.min.js') }}"></script>
    <!-- Odometer js -->
    <script src="{{ asset($activeTemplateTrue . '/js/odometer.min.js') }}"></script>
    <!-- Viewport js -->
    <script src="{{ asset($activeTemplateTrue . '/js/viewport.jquery.js') }}"></script>

    <!-- main js -->
    <script src="{{ asset($activeTemplateTrue . '/js/main.js') }}"></script>

    @stack('script-lib')

    @php echo loadExtension('tawk-chat') @endphp

    @include('partials.notify')

    @if (gs('pn'))
        @include('partials.push_script')
    @endif

    @stack('script')

    <script>
        (function($) {
            "use strict";

            $('.policy').on('click', function() {
                $.get('{{ route('cookie.accept') }}', function(response) {
                    $('.cookies-card').addClass('d-none');
                });
            });

            setTimeout(function() {
                $('.cookies-card').removeClass('hide')
            }, 2000);

            var inputElements = $('[type=text],[type=password],[type=email],[type=number],select,textarea');
            $.each(inputElements, function(index, element) {
                element = $(element);
                element.closest('.form-group').find('label').attr('for', element.attr('name'));
                element.attr('id', element.attr('name'))
            });

            $.each($('input, select, textarea'), function(i, element) {
                var elementType = $(element);
                if (elementType.attr('type') != 'checkbox') {
                    if (element.hasAttribute('required')) {
                        $(element).closest('.form-group').find('label').addClass('required');
                    }
                }
            });

            Array.from(document.querySelectorAll('table')).forEach(table => {
                let heading = table.querySelectorAll('thead tr th');
                Array.from(table.querySelectorAll('tbody tr')).forEach((row) => {
                    Array.from(row.querySelectorAll('td')).forEach((colum, i) => {
                        colum.setAttribute('data-label', heading[i].innerText)
                    });
                });
            });

            let disableSubmission = false;
            $('.disableSubmission').on('submit', function(e) {
                if (disableSubmission) {
                    e.preventDefault()
                } else {
                    disableSubmission = true;
                }
            });

        })(jQuery);
    </script>
</body>

</html>
