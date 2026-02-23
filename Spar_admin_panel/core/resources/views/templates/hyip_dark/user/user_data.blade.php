@extends($activeTemplate . 'layouts.frontend')

@section('content')
    <div class="my-60">
        <div class="container">
            <div class="row justify-content-center">
                <div class="col-lg-8">
                    <div class="card custom--card">
                        <div class="card-body">
                            <form method="POST" action="{{ route('user.data.submit') }}">
                                @csrf
                                <div class="row">
                                    @if (!$user->email)
                                        <div class="form-group col-sm-6">
                                            <label class="form--label">@lang('First Name')</label>
                                            <input type="text" class="form--control form-two" name="firstname" value="{{ old('firstname') }}" required placeholder="@lang('First Name')">
                                        </div>

                                        <div class="form-group col-sm-6">
                                            <label class="form--label">@lang('Last Name')</label>
                                            <input type="text" class="form--control form-two" name="lastname" value="{{ old('lastname') }}" required placeholder="@lang('Last Name')">
                                        </div>
                                        <div class="col-md-12">
                                            <div class="form-group">
                                                <label class="form--label">@lang('E-Mail Address')</label>
                                                <input type="email" class="form--control form-two checkUser" name="email" value="{{ old('email') }}" required placeholder="@lang('Email Address')">
                                                <small class="text-danger emailExist"></small>
                                            </div>
                                        </div>
                                    @endif

                                    <div class="col-md-12">
                                        <div class="form-group">
                                            <label class="form--label">@lang('Username')</label>
                                            <input type="text" class="form--control form-two checkUser" name="username" value="{{ old('username') }}" required placeholder="@lang('Username')">
                                            <small class="text-danger usernameExist"></small>
                                        </div>
                                    </div>
                                    
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label class="form--label">@lang('Country')</label>
                                            <select name="country" class="form--control select2">
                                                @foreach ($countries as $key => $country)
                                                    <option data-mobile_code="{{ $country->dial_code }}" value="{{ $country->country }}" data-code="{{ $key }}">
                                                        {{ __($country->country) }}</option>
                                                @endforeach
                                            </select>
                                        </div>
                                    </div>

                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label class="form--label">@lang('Mobile')</label>
                                            <div class="input-group ">
                                                <span class="input-group-text input-style mobile-code bg--base input-style">
                                                </span>
                                                <input type="hidden" name="mobile_code">
                                                <input type="hidden" name="country_code">
                                                <input type="number" name="mobile" value="{{ old('mobile') }}" class="form-control form--control form-two checkUser" required placeholder="@lang('Mobile')">
                                            </div>
                                            <small class="text-danger mobileExist"></small>
                                        </div>
                                    </div>

                                    <div class="form-group col-sm-6">
                                        <label class="form--label">@lang('Address')</label>
                                        <input type="text" class="form--control form-two" name="address" value="{{ old('address') }}" placeholder="@lang('Address')">
                                    </div>
                                    <div class="form-group col-sm-6">
                                        <label class="form--label">@lang('State')</label>
                                        <input type="text" class="form--control form-two" name="state" value="{{ old('state') }}" placeholder="@lang('State')">
                                    </div>
                                    <div class="form-group col-sm-6">
                                        <label class="form--label">@lang('Zip Code')</label>
                                        <input type="text" class="form--control form-two" name="zip" value="{{ old('zip') }}" placeholder="@lang('Zip')">
                                    </div>

                                    <div class="form-group col-sm-6">
                                        <label class="form--label">@lang('City')</label>
                                        <input type="text" class="form--control form-two" name="city" value="{{ old('city') }}" placeholder="@lang('City')">
                                    </div>
                                </div>
                                <div class="form-group mt-4">
                                    <button type="submit" class="btn btn--base btn--lg w-100">
                                        @lang('Submit')
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection

@push('script')
    <script>
        "use strict";
        (function($) {

            @if ($mobileCode)
                $(`option[data-code={{ $mobileCode }}]`).attr('selected', '');
            @endif

            $('select[name=country]').on('change', function() {
                $('input[name=mobile_code]').val($('select[name=country] :selected').data('mobile_code'));
                $('input[name=country_code]').val($('select[name=country] :selected').data('code'));
                $('.mobile-code').text('+' + $('select[name=country] :selected').data('mobile_code'));
                var value = $('[name=mobile]').val();
                var name = 'mobile';
                checkUser(value, name);
            });

            $('input[name=mobile_code]').val($('select[name=country] :selected').data('mobile_code'));
            $('input[name=country_code]').val($('select[name=country] :selected').data('code'));
            $('.mobile-code').text('+' + $('select[name=country] :selected').data('mobile_code'));

            $('.checkUser').on('focusout', function(e) {
                var value = $(this).val();
                var name = $(this).attr('name')
                checkUser(value, name);
            });

            function checkUser(value, name) {
                var url = '{{ route('user.checkUser') }}';
                var token = '{{ csrf_token() }}';

                if (name == 'mobile') {
                    var mobile = `${value}`;
                    var data = {
                        mobile: mobile,
                        mobile_code: $('.mobile-code').text().substr(1),
                        _token: token
                    }
                }
                if (name == 'email') {
                    var data = {
                        email: value,
                        _token: token
                    }
                }
                if (name == 'username') {
                    var data = {
                        username: value,
                        _token: token
                    }
                }
                $.post(url, data, function(response) {
                    if (response.data != false) {
                        $(`.${response.type}Exist`).text(`${response.field} already exist`);
                    } else {
                        $(`.${response.type}Exist`).text('');
                    }
                });
            }
        })(jQuery);
    </script>
@endpush
