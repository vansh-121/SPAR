@php
    $user = auth()->user();
    $userSupportEmail = getContent('user_support_email.content', true);
@endphp

<!-- Dashboard Header Start -->
<div class="dashboard-header">
    <div class="dashboard-header__inner d-flex justify-content-between align-items-center gap-2">
        <div class="dashboard-header__left">
            <div class="dashboard-body__bar d-lg-none d-block">
                <span class="dashboard-body__bar-icon"><i class="fas fa-bars"></i></span>
            </div>
            <div class="top-contact">
                <ul class="contact-list">
                    <li class="contact-list__item">
                        <span class="contact-list__item-icon">
                            <i class="fa-solid fa-headphones-simple"></i>
                        </span>
                        <p class="contact-list__item-text">
                            @lang('Support')
                        </p>
                    </li>
                    <li class="contact-list__item">
                        <span class="contact-list__item-icon">
                            <i class="fas fa-envelope"></i>
                        </span>
                        <p class="contact-list__item-text">
                            <a href="mailto:{{ @$userSupportEmail->data_values->email }}" class="contact-list__link"> {{ @$userSupportEmail->data_values->email }} </a>
                        </p>
                    </li>
                </ul>
            </div>
        </div>
        <div class="user-info">
            <div class="user-info__right">

                <div class="user-info__button">
                    <div class="user-info__thumb">
                    </div>
                    <div class="user-info__content">
                        <p class="user-info__name"> {{ __($user->fullname) }} </p>
                        <span class="user-info__mail"> {{ $user->email }} </span>
                    </div>
                </div>
            </div>
            <ul class="user-info-dropdown">
                <li class="user-info-dropdown__item">
                    <a class="user-info-dropdown__link" href="{{ route('user.profile.setting') }}">
                        <span class="icon"><i class="far fa-user-circle"></i></span>
                        <span class="text">@lang('My Profile')</span>
                    </a>
                </li>
                <li class="user-info-dropdown__item">
                    <a class="user-info-dropdown__link" href="{{ route('ticket.index') }}">
                        <span class="icon"><i class="fa-solid fa-headphones-simple"></i></span>
                        <span class="text">@lang('Support Ticket')</span>
                    </a>
                </li>
                <li class="user-info-dropdown__item">
                    <a class="user-info-dropdown__link" href="{{ route('user.logout') }}">
                        <span class="icon"><i class="fas fa-sign-out-alt"></i></span>
                        <span class="text">@lang('Logout')</span>
                    </a>
                </li>
            </ul>
        </div>
    </div>
</div>
<!-- Dashboard Header End -->
