@php
    $policies = getContent('policy_pages.element', false, null, true);
    $footer = getContent('footer.content', true);
    $socials = getContent('social_icon.element', false, null, true);
    $contacts = getContent('contact.element', false, null, true);
@endphp

<!-- Footer -->
<!-- ==================== Footer Start Here ==================== -->
<footer class="footer-area">
    <div class="footer-area__shape"></div>
    <div class="footer-area-wrapper">
        <div class="pb-60 pt-60">
            <div class="container">
                <div class="row justify-content-center gy-5">
                    <div class="col-sm-12 text-xl-center">
                        <div class="footer-item__logo">
                            <a href="{{ route('home') }}"> <img src="{{ siteLogo() }}" alt=""></a>
                        </div>
                    </div>
                    <div class="col-xl-4 col-sm-6 col-xsm-6">
                        <div class="footer-item">
                            <h5 class="footer-item__title"> @lang('About') {{ gs('site_name') }} </h5>
                            <p class="footer-item__desc">
                                {{ __(@$footer->data_values->description) }}
                            </p>
                            <ul class="social-list">
                                 @foreach ($socials as $social)
                                    <li class="social-list__item">
                                        <a class="social-list__link flex-center" href="{{ @$social->data_values->url }}" target="_blank">
                                            @php
                                                echo @$social->data_values->icon;
                                            @endphp
                                        </a>
                                    </li>
                                @endforeach
                            </ul>
                        </div>
                    </div>
                    <div class="col-xl-2 col-sm-6 col-xsm-6">
                        <div class="footer-item">
                            <h5 class="footer-item__title"> @lang('Useful Link') </h5>
                            <ul class="footer-menu">
                                <li class="footer-menu__item">
                                    <a href="{{ route('home') }}" class="footer-menu__link">@lang('Home')</a>
                                </li>
                                <li class="footer-menu__item">
                                    <a href="{{ route('blogs') }}" class="footer-menu__link">@lang('Blog')</a>
                                </li>
                                <li class="footer-menu__item">
                                    <a href="{{ route('contact') }}" class="footer-menu__link">@lang('Contact Us')</a>
                                </li>
                            </ul>
                        </div>
                    </div>
                    <div class="col-xl-3 col-sm-6 col-xsm-6">
                        <div class="footer-item">
                            <h5 class="footer-item__title"> @lang('Policy Pages') </h5>
                            <ul class="footer-menu">
                                <li class="footer-menu__item">
                                    <a href="{{ route('cookie.policy') }}" class="footer-menu__link">@lang('Cookie Policy')</a>
                                </li>
                                @foreach ($policies as $policy)
                                    <li class="footer-menu__item">
                                        <a href="{{ route('policy.pages', $policy->slug) }}" class="footer-menu__link">{{ __($policy->data_values->title) }}</a>
                                    </li>
                                @endforeach
                            </ul>
                        </div>
                    </div>
                    <div class="col-xl-3 col-sm-6 col-xsm-6">
                        <div class="footer-item">
                            <h5 class="footer-item__title"> @lang('Contact With Us') </h5>
                            <ul class="footer-contact-menu">
                                @foreach($contacts as $contact)
                                    <li class="footer-contact-menu__item">
                                        <div class="footer-contact-menu__item-icon">
                                            @php echo @$contact->data_values->icon; @endphp
                                        </div>
                                        <div class="footer-contact-menu__item-content">
                                            <p>{{ __(@$contact->data_values->content) }}</p>
                                        </div>
                                    </li>
                                @endforeach
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
            <!-- Footer Top End-->
        </div>
        <div class="bottom-footer py-3">
            <div class="row justify-content-center">
                <div class="col-md-6 text-center">
                    <div class="bottom-footer-text text-white"> &copy; @lang('Copyright') {{ date('Y') }}. @lang('All Rights Reserved')</div>
                </div>
            </div>
        </div>
    </div>
    <!-- bottom Footer -->
</footer>
<!-- ==================== Footer End Here ==================== -->

@push('style')
    <style>
        .footer-area-wrapper {
            background: url("{{ frontendImage('footer', @$footer->data_values->image, '1850x450') }}"), linear-gradient(174deg, hsl(var(--base-d-700)) -25.3%, #030504 100.96%);
        }
    </style>
@endpush