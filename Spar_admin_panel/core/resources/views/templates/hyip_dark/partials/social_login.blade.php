@php
    $text = request()->routeIs('user.register') ? 'Register' : 'Login';
@endphp

<div class="social-login-wrapper">
    <ul class="social-login-list">

        @if (@gs('socialite_credentials')->google->status == Status::ENABLE)
            <li class="social-login-list__item flex-grow-1">
                <a href="{{ route('user.social.login', 'google') }}" class="w-100 social-login-btn">
                    <span class="social-login-btn__icon">
                        <img src="{{ asset('assets/global/images/google.svg') }}" alt="@lang('image')" class="others-login-image"> 
                    </span>
                    @lang("$text with Google")
                </a>
            </li>
        @endif

        @if (@gs('socialite_credentials')->facebook->status == Status::ENABLE)
            <li class="social-login-list__item flex-grow-1">
                <a href="{{ route('user.social.login', 'facebook') }}" class="w-100 social-login-btn">
                    <span class="social-login-btn__icon">
                        <img src="{{ asset('assets/global/images/facebook.svg') }}" alt="@lang('image')" class="others-login-image">
                    </span>
                    @lang("$text with Facebook")
                </a>
            </li>
        @endif

        @if (@gs('socialite_credentials')->linkedin->status == Status::ENABLE)
            <li class="social-login-list__item flex-grow-1">
                <a href="{{ route('user.social.login', 'linkedin') }}" class="w-100 social-login-btn">
                    <span class="social-login-btn__icon">
                        <img src="{{ asset('assets/global/images/linkedin.svg') }}" alt="@lang('image')" class="others-login-image">
                    </span>
                    @lang("$text with Linkedin")
                </a>
            </li>
        @endif

        @if (gs('metamask_login'))
            <li class="social-login-list__item flex-grow-1">
                <button class="w-100 social-login-btn metamaskLogin">
                    <span class="social-login-btn__icon">
                        <img src="{{ asset($activeTemplateTrue . 'images/metamask.png') }}" alt="@lang('image')" class="others-login-image"> 
                    </span>
                    @lang("$text with Metamask")
                </button>
            </li>
        @endif

    </ul>
    
    @if (@gs('socialite_credentials')->linkedin->status || @gs('socialite_credentials')->facebook->status == Status::ENABLE || @gs('socialite_credentials')->google->status == Status::ENABLE || gs('metamask_login'))
        <div class="another-login">
            <span class="text"> @lang('or') </span>
        </div>
    @endif
</div>

@push('style')
    <style>
        .social-login-btn {
            border: 1px solid #cbc4c4;
        }

        .others-login-image {
            width: 22px;
        }
    </style>
@endpush

@if (gs('metamask_login'))
    @push('script-lib')
        <script src="{{ asset('assets/global/js/web3.min.js') }}"></script>
    @endpush

    @push('script')
        <script>
            var account = null;
            var signature = null;
            var message = 'Sign In';
            var token = null;
            $('.metamaskLogin').on('click', async () => {
                // detect wallet
                if (!window.ethereum) {
                    notify('error', 'MetaMask not detected. Please install MetaMask first.');
                    return;
                }

                // get wallet address
                await window.ethereum.request({
                    method: 'eth_requestAccounts'
                });
                window.web3 = new Web3(window.ethereum);
                accounts = await web3.eth.getAccounts();
                account = accounts[0];

                // get unique message
                let response = await fetch(`{{ route('user.login.metamask') }}`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({
                        'account': account,
                        '_token': '{{ csrf_token() }}'
                    })
                });
                message = (await response.json()).message;
                setTimeout(async () => {
                    // get signature
                    signature = await web3.eth.personal.sign(message, account);

                    // verify signature
                    response = await fetch(`{{ route('user.login.metamask.verify') }}`, {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json'
                        },
                        body: JSON.stringify({
                            'signature': signature,
                            '_token': '{{ csrf_token() }}'
                        })
                    });
                    response = await response.json();

                    notify(response.type, response.message);

                    // handle login
                    if (response.type == 'success') {
                        setTimeout(() => {
                            window.location.href = response.redirect_url;
                        }, 2000);
                    }
                }, 1500);

            })
        </script>
    @endpush
@endif
