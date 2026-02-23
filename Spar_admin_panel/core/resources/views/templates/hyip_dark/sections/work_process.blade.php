@php
    $workProcess = getContent('work_process.content', true);
    $workProcesses = getContent('work_process.element', false, null, true);
@endphp

<!--============= work process section start here ============= -->
<div class="work-process-section my-120">
    <div class="work-process-section__shape">
        <img src="{{ frontendImage('work_process', @$workProcess->data_values->background_image, '1920x975') }}" alt="">
    </div>
    <div class="container">
        <div class="row gy-4 align-items-center">
            <div class="col-xl-4 col-md-6">
                <div class="work-process-wrapper">
                    <h3 class="title">{{ __(@$workProcess->data_values->heading) }}</h3>
                    <div class="step-wrapper">
                        <div class="step-item">
                            <h5 class="step-item__title"> @lang('step 01') </h5>
                            <h6 class="step-item__commission"> {{ __(@$workProcess->data_values->step_1) }} </h6>
                            <div class="step-item__shape"></div>
                        </div>
                        <div class="step-item">
                            <h5 class="step-item__title"> @lang('step 02') </h5>
                            <h6 class="step-item__commission"> {{ __(@$workProcess->data_values->step_2) }} </h6>
                            <div class="step-item__shape"></div>
                        </div>
                        <div class="step-item">
                            <h5 class="step-item__title"> @lang('step 03') </h5>
                            <h6 class="step-item__commission"> {{ __(@$workProcess->data_values->step_3) }} </h6>
                            <div class="step-item__shape"></div>
                        </div>
                        <div class="step-item">
                            <h5 class="step-item__title"> @lang('step 04') </h5>
                            <h6 class="step-item__commission"> {{ __(@$workProcess->data_values->step_4) }} </h6>
                            <div class="step-item__shape"></div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-xl-4 d-xl-block d-none text-center">
                <img src="{{ frontendImage('work_process', @$workProcess->data_values->image, '345x535') }}" alt="">
            </div>
            <div class="col-xl-4 col-md-6">
                <div class="work-process-wrapper">
                    <h3 class="title">{{ __(@$workProcess->data_values->right_side_heading) }}</h3>
                    <img src="{{ frontendImage('work_process', @$workProcess->data_values->right_side_image, '410x395') }}" alt="">
                </div>
            </div>
        </div>
    </div>
</div>
<!--=============== work process section end here ============= -->