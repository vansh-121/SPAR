@extends($activeTemplate . 'layouts.frontend')

@section('content')
    <!-- ==================== Blog Start Here ==================== -->
    <section class="blog-detials mb-120 mt-60">
        <div class="container">
            <div class="row gy-5 justify-content-center">
                <div class="col-xl-9 col-lg-8 pe-lg-5">
                    <div class="blog-details">
                        <div class="blog-details__thumb">
                            <img src="{{ frontendImage('blog', @$blog->data_values->image, '930x480') }}" class="fit-image" alt="">
                            <div class="blog-item__date">
                                <h3 class="date-time"> {{ showDateTime(@$blog->created_at, 'd') }} </h3>
                                <p class="month"> {{ showDateTime(@$blog->created_at, 'M') }} </p>
                            </div>
                        </div>
                        <div class="blog-details__content">
                            <div>
                                @php echo @$blog->data_values->description @endphp
                            </div>
                            <div class="blog-details__content-bottom">
                                <span class="blog-details__subtitle mb-0"> @lang('Post by Admin') </span>
                                <div class="blog-details__share d-flex align-items-center flex-wrap">
                                    <h5 class="social-share__title mb-0 me-sm-3 me-1 d-inline-block">@lang('Share')</h5>
                                    <ul class="social-list list-two">
                                        <li class="social-list__item">
                                            <a target="_blank" class="social-list__link flex-center" href="https://www.facebook.com/sharer/sharer.php?u={{ urlencode(url()->current()) }}">
                                                <i class="fab fa-facebook-f"></i>
                                            </a>
                                        </li>
                                        <li class="social-list__item">
                                            <a target="_blank" class="social-list__link flex-center" href="https://twitter.com/intent/tweet?text={{ __(@$blog->data_values->title) }}&amp;url={{ urlencode(url()->current()) }}">
                                                <i class="fab fa-twitter"></i>
                                            </a>
                                        </li>
                                        <li class="social-list__item">
                                            <a target="_blank" class="social-list__link flex-center" href="http://www.linkedin.com/shareArticle?mini=true&amp;url={{ urlencode(url()->current()) }}&amp;title={{ __
                                            (@$blog->data_values->title) }}&amp;summary=dit is de linkedin summary">
                                                <i class="fab fa-linkedin"></i>
                                            </a>
                                        </li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                        <div class="comments-area">
                            <div class="comment-area comments-list">
                                <div class="fb-comments" data-href="{{ url()->current() }}" data-numposts="5"></div>
                            </div>
                        </div><!-- comments-area end -->
                    </div>
                </div>
                <div class="col-xl-3 col-lg-4">
                    <!-- ============================= Blog Details Sidebar Start ======================== -->
                    <div class="blog-sidebar">
                        <div class="sidebar-item">
                            <h6 class="sidebar-item__title"> @lang('Latest blogs') </h6>
                            <div class="sidebar-item__content">
                                @foreach ($blogs as $data)
                                    <div class="latest-blog">
                                        <div class="latest-blog__thumb">
                                            <a href="{{ route('blog.details', $data->slug) }}"> 
                                                <img src="{{ frontendImage('blog' , 'thumb_'. @$data->data_values->image, '460x240') }}" class="fit-image" alt="">
                                            </a>
                                        </div>
                                        <div class="latest-blog__content">
                                            <h6 class="latest-blog__title">
                                                <a href="{{ route('blog.details', $data->slug) }}">{{ strLimit(@$data->data_values->title, 57) }}</a>
                                            </h6>
                                            <span class="latest-blog__date fs-12"> {{ showDateTime(@$blog->created_at, 'd M Y') }}</span>
                                        </div>
                                    </div>
                                @endforeach
                            </div>
                        </div>
                    </div>
                    <!-- ============================= Blog Details Sidebar End ======================== -->
                </div>
            </div>
        </div>
    </section>
    <!-- ==================== Blog End Here ==================== -->
@endsection

@push('fbComment')
    @php echo loadExtension('fb-comment') @endphp
@endpush
