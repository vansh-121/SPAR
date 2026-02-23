@extends($activeTemplate.'layouts.frontend')

@section('content')
    <div class="my-120">
        <div class="container">
            @php
                echo $cookie->data_values->description
            @endphp
        </div>
    </div>
@endsection
 