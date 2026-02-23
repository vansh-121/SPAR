@extends($activeTemplate . 'layouts.app')

@php
    $policyPages = getContent('policy_pages.element', false, null, true);
    $registerContent = getContent('registration.content', true);
@endphp

@section('panel')
    <section class="account py-60">
        <div class="account__shape">
            <img src="{{ asset($activeTemplateTrue .'images/shapes/contact-s.png') }}" alt="">
        </div>
        <div class="container">
            <div class="row gy-4 justify-content-center">
                <div class="col-sm-12">
                    <a href="{{ route('home') }}" class="account-form__logo">
                        <img src="{{ siteLogo() }}" alt="">
                    </a>
                </div>
                <div class="col-lg-6 pe-lg-5 d-lg-block d-none">
                    <div class="account-thumb">
                        <img src="{{ frontendImage('registration', @$registerContent->data_values->image, '640x620') }}" alt="">
                    </div>
                </div>
                <div class="col-lg-6">
                    <form action="{{ route('user.register') }}" method="POST" class="verify-gcaptcha account-form">
                        @csrf

                        <span class="account-form__shape"></span>
                        <span class="account-form__subtitle"> {{ __(@$registerContent->data_values->subheading) }} </span>
                        <h5 class="account-form__title"> {{ __(@$registerContent->data_values->heading) }} </h5>

                        @include($activeTemplate.'partials.social_login')   

                        <div class="row gy-4">

                            @if (session()->get('reference') != null)
                                <div class="col-md-12">
                                    <p>@lang('You\'re referred by') <i class="fw-bold base--color">{{ session()->get('reference') }}</i></p>
                                </div>
                            @endif

                            <div class="col-sm-6">
                                <label for="firstname" class="form--label"> @lang('First Name') </label>
                                <input type="text" class="form--control form-two" name="firstname" value="{{ old('firstname') }}" required placeholder="@lang('First Name')" id="firstname">
                            </div>
                            <div class="col-sm-6">
                                <label for="lastname" class="form--label"> @lang('Last Name') </label>
                                <input type="text" class="form--control" name="lastname" value="{{ old('lastname') }}" required placeholder="@lang('Last Name')" id="lastname">
                            </div>
                            <div class="col-md-12">
                                <label for="email" class="form--label"> @lang('E-Mail Address') </label>
                                <input type="email" class="form--control form-two checkUser" name="email" value="{{ old('email') }}" required placeholder="@lang('Email')" id="email">
                            </div>

                            <div class="col-sm-6">
                                <label for="password" class="form--label">@lang('Password')</label>
                                <div class="position-relative">
                                    <input type="password" class="form--control form-two @if (gs('secure_password')) secure-password @endif" name="password" required id="password" placeholder="@lang('Password')">
                                    <span class="password-show-hide fa-solid fa-eye-slash toggle-password"
                                        id="#password"></span>
                                </div>
                            </div>
                            <div class="col-sm-6">
                                <label for="password_confirmation" class="form--label">@lang('Confirm Password')</label>
                                <div class="position-relative">
                                    <input type="password" class="form--control form-two" name="password_confirmation" required id="password_confirmation" placeholder="@lang('Confirm Password')">
                                    <div class="password-show-hide fa-solid fa-eye-slash toggle-password"
                                        id="#password_confirmation"></div>
                                </div>
                            </div>

                            <x-captcha />

                            <div class="form-group form--check flex-nowrap">
                                <input class="form-check-input" type="checkbox" id="agree" @checked(old('agree')) name="agree" required>
                                <label class="form-check-label" for="agree">@lang('I agree with')

                                    <span>
                                        @foreach ($policyPages as $policy)
                                            <a href="{{ route('policy.pages', $policy->slug) }}" target="_blank">{{ __($policy->data_values->title) }}</a>
                                            @if (!$loop->last)
                                                ,
                                            @endif
                                        @endforeach
                                    </span>
                                    </label> 
                            </div>

                            <div class="col-sm-12 form-group mt-4">
                                <button type="submit" class="btn btn--base btn--lg w-100"> @lang('Register') </button>
                            </div>
                        </div>
                        <p class="account-form__text"> @lang('Already have an account?')
                            <a href="{{ route('user.login') }}" class="text--base"> @lang('Login') </a>
                        </p>
                    </form>
                </div>
            </div>
        </div>
    </section>

    <div class="modal fade" id="existModalCenter" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-dialog-centered" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h6 class="modal-title" id="existModalLongTitle">@lang('You are with us')</h6>
                    <button type="button" class="close" data-bs-dismiss="modal" aria-label="Close">
                        <i class="fas fa-times"></i>
                    </button>
                </div>
                <div class="modal-body">
                    <h6 class="text-center">@lang('You already have an account please Login ')</h6>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn--danger" data-bs-dismiss="modal">@lang('Close')</button>
                    <a href="{{ route('user.login') }}" class="btn btn--base">@lang('Login')</a>
                </div>
            </div>
        </div>
    </div>
@endsection

@push('style')
    <style>
        .country-code .input-group-text {
            background: #fff !important;
        }

        .country-code select {
            border: none;
        }

        .country-code select:focus {
            border: none;
            outline: none;
        }
    </style>
@endpush

@if (gs('secure_password'))
    @push('script-lib')
        <script src="{{ asset('assets/global/js/secure_password.js') }}"></script>
    @endpush
@endif

@push('style')
<style>
    .hover-input-popup .input-popup {
        bottom: calc(100% + 6px);
    }
</style>
@endpush

@push('script')
    <script>
        "use strict";
        (function($) {

            $('.checkUser').on('focusout', function(e) {
                var url = '{{ route('user.checkUser') }}';
                var value = $(this).val();
                var token = '{{ csrf_token() }}';

                var data = {
                    email: value,
                    _token: token
                }

                $.post(url, data, function(response) {
                    if (response.data != false) {
                        $('#existModalCenter').modal('show');
                    }
                });
            });
        })(jQuery);
    </script>
@endpush
