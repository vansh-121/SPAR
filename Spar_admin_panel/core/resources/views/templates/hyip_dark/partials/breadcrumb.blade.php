@php
    $breadcrumb = getContent('breadcrumb.content', true);
@endphp

<section class="breadcrumb">
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-lg-8">
                <div class="breadcrumb__wrapper">
                    <h3 class="breadcrumb__title"> {{ __($pageTitle) }} </h3>
                     <ul class="breadcrumb-list">
                        <li class="breadcrumb-list__item">
                            <a href="{{ route('home') }}" class="breadcrumb-list__link"> @lang('Home') </a> //
                        </li>
                        <li class="breadcrumb-list__item"> 
                            @if(request()->routeIs('blog.details'))
                                @lang('Blog Details')
                            @else 
                                {{ __($pageTitle) }} 
                            @endif
                        </li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
</section>

@push('style')
    <style>
        .breadcrumb {
            background-image: url("{{ frontendImage('breadcrumb', @$breadcrumb->data_values->image, '1920x435') }}");
        }
    </style>
@endpush
