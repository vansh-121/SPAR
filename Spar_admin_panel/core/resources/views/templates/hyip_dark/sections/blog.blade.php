@php
    $blog = getContent('blog.content', true);
    $blogs = getContent('blog.element', false, 3);
@endphp

<!-- ==================== Blog Start Here ==================== -->
<section class="blog my-120">
    <div class="container">
        <div class="section-heading">
            <span class="section-heading__shape"></span>
            <h3 class="section-heading__title"> {{ __(@$blog->data_values->heading) }} </h3>
            <p class="section-heading__desc">{{ __(@$blog->data_values->subheading) }}</p>
        </div>
        <div class="row gy-4 justify-content-center">
            @foreach($blogs as $item)
                <div class="col-lg-4 col-md-6">
                    <div class="blog-item">
                        <div class="blog-item__thumb">
                            <a href="{{ route('blog.details', $item->slug) }}" class="blog-item__thumb-link">
                                <img class="image1" src="{{ frontendImage('blog' , 'thumb_'. @$item->data_values->image, '460x240') }}" alt="img1">
                                <img class="image2" src="{{ frontendImage('blog' , 'thumb_'. @$item->data_values->image, '460x240') }}" alt="img2">
                            </a>
                            <div class="blog-item__date">
                                <h3 class="date-time"> {{ showDateTime(@$blog->created_at, 'd') }} </h3>
                                <p class="month"> {{ showDateTime(@$blog->created_at, 'M') }} </p>
                            </div>
                        </div>
                        <div class="blog-item__content">
                            <h5 class="blog-item__title">
                                <a href="{{ route('blog.details', $item->slug) }}" class="blog-item__title-link">
                                    {{ strLimit(@$item->data_values->title, 57) }}
                                </a>
                            </h5>
                            <ul class="text-list flex-align gap-3">
                                <li class="text-list__item">
                                    @lang('Post By Admin')
                                </li>
                            </ul>
                        </div>
                    </div>
                </div>
            @endforeach
        </div>
    </div>
</section>
<!-- ==================== Blog End Here ==================== -->