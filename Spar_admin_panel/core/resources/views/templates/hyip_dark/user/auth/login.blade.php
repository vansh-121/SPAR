@extends($activeTemplate . 'layouts.app')

@php
    $loginContent = getContent('login.content', true);
@endphp

@section('panel')
    <!-- ================================= Account Section Start Here ============================ -->
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
                        <img src="{{ frontendImage('login', @$loginContent->data_values->image, '640x620') }}" alt="">
                    </div>
                </div>
                <div class="col-lg-6">
                    <form method="POST" action="{{ route('user.login') }}" class="verify-gcaptcha account-form">
                        @csrf

                        <span class="account-form__shape"></span>
                        <span class="account-form__subtitle"> {{ __(@$loginContent->data_values->subheading) }} </span>
                        <h5 class="account-form__title"> {{ __(@$loginContent->data_values->heading) }} </h5>
                        
                        @include($activeTemplate.'partials.social_login')

                        <div class="row gy-4">
                            <div class="col-sm-12 ">
                                <label for="username" class="form--label"> @lang('Username') </label>
                                <input 
                                    type="text" 
                                    name="username" 
                                    value="{{ old('username') }}" 
                                    class="form--control form-two" 
                                    required 
                                    placeholder="@lang('Username')"
                                >
                            </div>
                            <div class="col-sm-12">
                                <label for="password" class="form--label">@lang('Password')</label>
                                <div class="position-relative">
                                    <input 
                                        id="password" 
                                        name="password" 
                                        type="password" 
                                        class="form--control form-two" 
                                        placeholder="@lang('Password')"
                                    >
                                    <span class="password-show-hide fa-solid fa-eye-slash toggle-password" id="#password"></span>
                                </div>
                            </div>
                            <div class="col-sm-12 form-group">
                                <div class="flex-between">
                                    <div class="form--check flex-nowrap">
                                        <input class="form-check-input" type="checkbox" name="remember" id="flexCheckChecked" {{ old('remember') ? 'checked' : '' }}>
                                        <label class="form-check-label" for="flexCheckChecked">
                                            @lang('Remember Me')
                                        </label>
                                    </div>
                                    <a href="{{ route('user.password.request') }}" class="forgot-password"> @lang('Forgot password?') </a>
                                </div>
                            </div>

                            <x-captcha />

                            <div class="col-sm-12 form-group mt-4">
                                <button type="submit" class="btn btn--base btn--lg w-100"> @lang('LOGIN') </button>
                            </div>
                        </div>
                        <p class="account-form__text"> @lang("Don't have on account yet?")
                            <a href="{{ route('user.register') }}" class="text--base"> @lang('Create Account') </a>
                        </p>
                    </form>
                </div>
            </div>
        </div>
    </section>
    <!-- ================================= Account Section End Here ============================ -->
@endsection
