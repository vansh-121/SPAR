@extends($activeTemplate.'layouts.frontend')

@section('content')
    <div class="my-120">
        <div class="container">
            @php
                echo $policy->data_values->details;
            @endphp
        </div>
    </div>
@endsection
