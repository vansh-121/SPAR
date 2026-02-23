@php
    $userBreadcrumb = getContent('user_breadcrumb.content', true);
@endphp

<!-- dashboard breadcrumb start here  -->
<section class="dashboard-breadcrumb">
    <div class="dashboard-breadcrumb__thumb">
        <img src="{{ frontendImage('user_breadcrumb', @$userBreadcrumb->data_values->image, '1500x210') }}" alt="">
    </div>
    <div class="container-fluid p-0">
        <div class="row justify-content-center">
            <div class="col-lg-8">
                <div class="dashboard-breadcrumb__wrapper">
                    <h3 class="dashboard-breadcrumb__title"> {{ __($pageTitle) }} </h3>
                    <ul class="breadcrumb-list">
                        <li class="breadcrumb-list__item">
                            <a href="{{ route('home') }}" class="breadcrumb-list__link"> @lang('Home') </a> //
                        </li>
                        <li class="breadcrumb-list__item"> {{ __($pageTitle) }} </li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
</section>
<!-- dashboard breadcrumb start here  -->