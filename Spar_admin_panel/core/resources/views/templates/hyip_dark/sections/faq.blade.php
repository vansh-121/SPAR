@php
    $faq = getContent('faq.content', true);
    $faqs = getContent('faq.element', false, null, true);
@endphp

<!--=============== faq section start here =============== -->
<div class="faq-section my-120">
    <div class="faq-section__shape">
        <img src="{{ frontendImage('faq', @$faq->data_values->background_image, '585x585') }}" alt="">
    </div>
    <div class="container">
        <div class="section-heading">
            <h3 class="section-heading__title"> {{ __(@$faq->data_values->heading) }} </h3>
            <p class="section-heading__desc">{{ __(@$faq->data_values->subheading) }}</p>
        </div>
        <div class="row gy-4 justify-content-between align-items-center">
            <div class="col-xl-6 col-lg-7 pe-xxl-5">
                <div class="accordion custom--accordion" id="accordionExample">
                    
                    @foreach ($faqs as $item)
                        <div class="accordion-item">
                            <h5 class="accordion-header" id="heading{{ $loop->index }}">
                                <button class="accordion-button" type="button" data-bs-toggle="collapse"
                                    data-bs-target="#collapse{{ $loop->index }}" aria-expanded="{{ $loop->first ? 'true' : 'false' }}"
                                    aria-controls="collapse{{ $loop->index }}">
                                    {{ __($item->data_values->question) }}
                                </button>
                            </h5>
                            <div id="collapse{{ $loop->index }}" class="accordion-collapse collapse {{ $loop->first ? 'show' : '' }}"
                                aria-labelledby="heading{{ $loop->index }}" data-bs-parent="#accordionExample">
                                <div class="accordion-body">
                                    <p class="text">{{ __($item->data_values->answer) }}</p>
                                </div>
                            </div>
                        </div>  
                    @endforeach

                </div>
            </div>
            <div class="col-xl-6 col-lg-5 ps-xl-5 d-lg-block d-none">
                <div class="faq-thumb-wrapper">
                    <div class="faq-thumb-wrapper__shape"></div>
                    <div class="thumb">
                        <img src="{{ frontendImage('faq', @$faq->data_values->image, '385x445') }}" alt="">
                    </div>
                    <div class="shape-two"></div>
                </div>
            </div>
        </div>
    </div>
</div>
<!--=============== faq section end here =============== -->