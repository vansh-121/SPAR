@php
    $testimonial = getContent('testimonial.content', true);
    $testimonials = getContent('testimonial.element', false, null, true);
@endphp

<!--========================== Testimonials Section Start ==========================-->
<section class="testimonials my-120">
    <div class="container">
        <div class="section-heading">
            <div class="section-heading__shape"></div>
            <h1 class="section-heading__title"> {{ __(@$testimonial->data_values->heading) }} </h1>
            <p class="section-heading__desc">{{ __(@$testimonial->data_values->subheading) }}</p>
        </div>
        <div class="testimonial-slider">
            @foreach($testimonials as $item)
                <div class="testimonails-card">
                    <div class="testimonial-item">
                        <div class="testimonial-item__content">
                            <div class="testimonial-item__info">
                                <div class="testimonial-item__thumb">
                                    <img src="{{ frontendImage('testimonial', @$item->data_values->image, '90x90') }}" class="fit-image" alt="">
                                </div>
                                <div class="testimonial-item__details">
                                    <h5 class="testimonial-item__name"> {{ __(@$item->data_values->name) }} </h5>
                                    <span class="testimonial-item__designation"> {{ __(@$item->data_values->designation) }} </span>
                                    <div class="testimonial-item__rating">
                                        <span class="icon">
                                            <i class="fas fa-star"></i>
                                        </span>
                                        <span class="number"> {{ __(@$item->data_values->rating) }}</span>
                                    </div>
                                </div>
                            </div>

                        </div>
                        <p class="testimonial-item__desc">
                            {{ __(@$item->data_values->quote) }}
                        </p>
                        <span class="testimonial-item__icon"></span>
                    </div>
                </div>
            @endforeach
        </div>
    </div>
</section>
<!--========================== Testimonials Section End ==========================-->