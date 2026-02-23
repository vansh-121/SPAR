@php
    $whyChoose = getContent('why_choose.content', true);
    $whyChooses = getContent('why_choose.element', false, null, true);
@endphp

<!--====== why choose section start here ====== -->
<div class="choose-us-section my-120">
    <div class="container">
        <div class="row gy-4 align-items-center">
            <div class="col-xl-7 col-lg-6">
                <div class="choose-content">
                    <div class="section-heading style-left">
                        <h3 class="section-heading__title"> {{ __(@$whyChoose->data_values->heading) }} </h3>
                        <p class="section-heading__desc">
                            {{ __(@$whyChoose->data_values->subheading) }}
                        </p>
                    </div>
                    <div class="choose-item-wrapper">
                        @foreach($whyChooses->chunk(2) as $chunk)
                            <div class="choose-item-wrapper__content">
                                @foreach($chunk as $item)
                                    <div class="choose-item">
                                        <p class="choose-item__title">{{ __(@$item->data_values->title) }}</p>
                                    </div>
                                @endforeach
                            </div>
                        @endforeach
                    </div>
                </div>
            </div>
            <div class="col-xl-5 col-lg-6">
                <div class="why-choose-thumb">
                    <img src="{{ frontendImage('why_choose', @$whyChoose->data_values->image, '700x680') }}" alt="">
                </div>
            </div>
        </div>
    </div>
</div>
<!--====== why choose section end here ====== -->