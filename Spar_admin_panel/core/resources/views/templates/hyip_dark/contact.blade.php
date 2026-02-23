@extends($activeTemplate . 'layouts.frontend')

@php
    $contactContent = getContent('contact.content', true);
    $contactElements = getContent('contact.element', null, false, true);
@endphp

@section('content')
    <!-- ==================== contact Start Here ==================== -->
    <div class="contact-section my-60">
        <div class="contact-section__shape">
            <img src="{{ asset($activeTemplateTrue. 'images/shapes/contact-s.png') }}" alt="">
        </div>
        <div class="container">
            <div class="row justify-content-center">
                <div class="col-xl-10">
                    <div class="contact-top">
                        <div class="row gy-5 justify-content-center">
                            @foreach($contactElements as $contactElement)
                                <div class="col-lg-4 col-sm-6">
                                    <div class="contact-item">
                                        <div class="contact-item__shape"></div>
                                        <div class="contact-item__icon">
                                            @php echo @$contactElement->data_values->icon; @endphp
                                        </div>
                                        <div class="contact-item__content">
                                            <h5 class="contact-item__title"> {{ __(@$contactElement->data_values->title) }} </h5>
                                            <p class="contact-item__desc">{{ __(@$contactElement->data_values->content) }}</p>
                                        </div>
                                    </div>
                                </div>
                            @endforeach
                        </div>
                    </div>
                </div>
            </div>
            <div class="contact-bottom mt-120">
                <div class="row gy-4 align-items-center justify-content-center">
                    <div class="col-lg-6 pe-xl-5">
                        <div class="contact-bottom__thumb">
                            <img src="{{ frontendImage('contact', @$contactContent->data_values->image, '640x620') }}" alt="">
                        </div>
                    </div>
                    <div class="col-lg-6 ps-lg-5">
                        <div class="contact-form">
                            <span class="contact-form__shape"></span>
                            <span class="contact-form__subtitle"> {{ __(@$contactContent->data_values->heading) }}  </span>
                            <h5 class="contact-form__title"> {{ __(@$contactContent->data_values->subheading) }} </h5>
                            <form action="{{ route('contact') }}" method="post" class="contact-form verify-gcaptcha">
                                @csrf
                                <div class="row gy-4">
                                    <div class="col-sm-12">
                                        <label class="form--label">@lang('Name') </label>
                                        <input type="text" name="name" class="form-control form--control" value="{{ old('name', @$user->fullname) }}" @if ($user && $user->profile_complete) readonly @endif required placeholder="@lang('Full Name')">
                                    </div>
                                    <div class="col-sm-12">
                                        <label class="form--label">@lang('Email') </label>
                                        <input type="email" name="email" class="form-control form--control" value="{{ old('email', @$user->email) }}" @if ($user) readonly @endif required placeholder="@lang('Email Address')">
                                    </div>
                                    <div class="col-sm-12">
                                        <label class="form--label">@lang('Subject') </label>
                                        <input name="subject" class="form-control form--control" required placeholder="@lang('Subject')">
                                    </div>
                                    <div class="col-sm-12">
                                        <label class="form--label">@lang('Subject') </label>
                                        <textarea cols="30" rows="10" class="form-control form--control" name="message" required placeholder="@lang('Write message').."></textarea>
                                    </div>
                                    <div class="col-sm-12">
                                        <x-captcha />
                                    </div>
                                </div>

                                <div class="contact-form__btn">
                                    <button type="submit" class="btn btn--base w-100 btn--lg"> @lang('Send Message') </button>
                                </div>
                            </form>
                        </div>
                    </div>

                </div>
            </div>
        </div>
    </div>
    <!-- ==================== contact End Here ==================== -->

    @if(@$sections->secs != null)
        @foreach(json_decode($sections->secs) as $sec)
            @include($activeTemplate.'sections.'.$sec)
        @endforeach
    @endif
@endsection
