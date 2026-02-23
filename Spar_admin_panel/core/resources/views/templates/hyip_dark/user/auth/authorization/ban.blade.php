@extends($activeTemplate .'layouts.frontend')

@section('content')
    <div class="my-120">
        <div class="container">
            <div class="row justify-content-center">
                <div class="col-md-6">
                    <div class="card custom--card">
                        <div class="card-body">
                            <div class="ban-content">
                                <span class="icon">
                                    <i class="las la-ban"></i>
                                </span>
                                <h3 class="text-center text-danger mb-3">@lang('You are banned')</h3>
                                <p>{{ __($user->ban_reason) }}</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection
