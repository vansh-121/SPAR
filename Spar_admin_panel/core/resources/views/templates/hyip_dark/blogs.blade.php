@extends($activeTemplate . 'layouts.frontend')

@section('content')
    <div class="blog-section my-120">
        <div class="container">
            <div class="row gy-4 justify-content-center">
                @forelse ($blogs as $k => $data)
                    <div class="col-lg-4 col-md-6">
                        <div class="blog-item">
                            <div class="blog-item__thumb">
                                <a href="{{ route('blog.details', $data->slug) }}" class="blog-item__thumb-link">
                                    <img class="image1" src="{{ frontendImage('blog' , 'thumb_'. @$data->data_values->image, '460x240') }}" alt="img1">
                                    <img class="image2" src="{{ frontendImage('blog' , 'thumb_'. @$data->data_values->image, '460x240') }}" alt="img2">
                                </a>
                                <div class="blog-item__date">
                                    <h3 class="date-time"> {{ showDateTime(@$data->created_at, 'd') }} </h3>
                                    <p class="month"> {{ showDateTime(@$data->created_at, 'M') }} </p>
                                </div>
                            </div>
                            <div class="blog-item__content">
                                <h5 class="blog-item__title">
                                    <a href="{{ route('blog.details', $data->slug) }}" class="blog-item__title-link">
                                        {{ strLimit(@$data->data_values->title, 57) }}
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
                @empty
                    @include($activeTemplate . 'partials.empty')
                @endforelse
            </div>
            {{ paginateLinks($blogs) }}
        </div>
    </div>

    @if ($sections != null)
        @foreach (json_decode($sections) as $sec)
            @include($activeTemplate . 'sections.' . $sec)
        @endforeach
    @endif
@endsection
