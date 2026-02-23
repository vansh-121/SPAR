@extends($activeTemplate .'layouts.frontend')

@section('content')
    <div class="my-120">
        <div class="container">
            <div class="d-flex justify-content-center">
                <div class="verification-code-wrapper">
                    <div class="verification-area">
                        <form action="{{route('user.2fa.verify')}}" method="POST" class="submit-form">
                            @csrf
                            <p class="verification-text mb-3">@lang('Enter the 6-digit verification code from your Google Authenticator app')</p>

                            @include($activeTemplate.'partials.verification_code')

                            <div class="form--group">
                                <button type="submit" class="btn btn--base w-100 btn--lg">@lang('Submit')</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection
