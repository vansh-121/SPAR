@php
    $user = auth()->user();
    $promotionCount = App\Models\PromotionTool::count();
@endphp

<!-- ====================== Sidebar menu Start ========================= -->
<div class="sidebar-menu flex-between">
    <div class="sidebar-menu__inner">
        <span class="sidebar-menu__close d-lg-none d-block"><i class="fas fa-times"></i></span>
        <!-- Sidebar Logo Start -->
        <div class="sidebar-logo">
            <a href="{{ route('home') }}" class="sidebar-logo__link">
                <img src="{{ siteLogo() }}" alt="">
            </a>
        </div>

        <!-- Sidebar Logo End -->
        <div class="sidebar-menu__account">
            <div class="shape"></div>
            <h6 class="title"> @lang('Account Balance') </h6>
            <p class="text"> 
                <span class="number"> {{ showAmount($user->deposit_wallet, currencyFormat:false) }} </span> 
                {{ gs('cur_text') }}(@lang('Deposit')) @lang('Wallet') 
            </p>
            <p class="text"> 
                <span class="number"> {{ showAmount($user->interest_wallet, currencyFormat:false) }} </span> 
                {{ gs('cur_text') }}(@lang('Interest')) @lang('Wallet') 
            </p>
        </div>

        <!-- ========= Sidebar Menu Start ================ -->
        <ul class="sidebar-menu-list">

            <li class="sidebar-menu-list__item {{ menuActive('user.home') }}">
                <a href="{{ route('user.home') }}" class="sidebar-menu-list__link">
                    <span class="icon"> <i class="fa-solid fa-border-all"></i> </span>
                    <span class="text">@lang('Dashboard')</span>
                </a>
            </li>

            <li 
                class="sidebar-menu-list__item has-dropdown 
                {{ menuActive([
                    'plan', 
                    'user.staking.index', 
                    'user.pool.index', 
                    'user.invest.schedule', 
                    'user.invest.statistics', 
                    'user.invest.details',
                    'user.invest.log',
                    'user.pool.invests',
                ]) }}"
            >
                <a href="javascript:void(0)" class="sidebar-menu-list__link">
                    <span class="icon"><i class="fa-solid fa-coins"></i></span>
                    <span class="text"> @lang('Investment') </span>
                </a>
                <div class="sidebar-submenu">
                    <ul class="sidebar-submenu-list">
                        <li class="sidebar-submenu-list__item {{ menuActive('plan') }}">
                            <a href="{{ route('plan') }}" class="sidebar-submenu-list__link">@lang('Plan')</a>
                        </li>
                        @if (gs('staking_option'))
                            <li class="sidebar-submenu-list__item {{ menuActive('user.staking.index') }}">
                                <a href="{{ route('user.staking.index') }}" class="sidebar-submenu-list__link">@lang('My Staking')</a>
                            </li>
                        @endif
                        @if (gs('pool_option'))
                            <li class="sidebar-submenu-list__item {{ menuActive('user.pool.index') }}">
                                <a href="{{ route('user.pool.index') }}" class="sidebar-submenu-list__link">@lang('Pool')</a>
                            </li>
                        @endif
                        @if (gs('schedule_invest'))
                            <li class="sidebar-submenu-list__item {{ menuActive('user.invest.schedule') }}">
                                <a href="{{ route('user.invest.schedule') }}" class="sidebar-submenu-list__link">@lang('Schedule')</a>
                            </li>
                        @endif
                    </ul>
                </div>
            </li>

            <li 
                class="sidebar-menu-list__item has-dropdown 
                {{ menuActive([
                    'user.deposit.index',
                    'user.withdraw',
                    'user.transfer.balance',
                    'user.transactions',
                    'user.deposit.manual.confirm',
                    'user.deposit.history',
                    'user.deposit.confirm',
                    'user.withdraw.history',
                ]) }}"
            >
                <a href="javascript:void(0)" class="sidebar-menu-list__link">
                    <span class="icon"><i class="fa-solid fa-money-bill-transfer"></i></span>
                    <span class="text"> @lang('Finance') </span>
                </a>
                <div class="sidebar-submenu">
                    <ul class="sidebar-submenu-list">
                        <li class="sidebar-submenu-list__item {{ menuActive('user.deposit.index') }}">
                            <a href="{{ route('user.deposit.index') }}" class="sidebar-submenu-list__link">@lang('Deposit')</a>
                        </li>
                        <li class="sidebar-submenu-list__item {{ menuActive('user.withdraw') }}">
                            <a href="{{ route('user.withdraw') }}" class="sidebar-submenu-list__link">@lang('Withdraw')</a>
                        </li>
                        @if (gs('b_transfer'))
                            <li class="sidebar-submenu-list__item {{ menuActive('user.transfer.balance') }}">
                                <a href="{{ route('user.transfer.balance') }}" class="sidebar-submenu-list__link">@lang('Transfer Balance')</a>
                            </li>
                        @endif
                        <li class="sidebar-submenu-list__item {{ menuActive('user.transactions') }}">
                            <a href="{{ route('user.transactions') }}" class="sidebar-submenu-list__link">@lang('Transactions')</a>
                        </li>
                    </ul>
                </div>
            </li>

            <li class="sidebar-menu-list__item {{ menuActive('user.referrals') }}">
                <a href="{{ route('user.referrals') }}" class="sidebar-menu-list__link">
                    <span class="icon"> <i class="fa-solid fa-users"></i> </span>
                    <span class="text">@lang('Referrals')</span>
                </a>
            </li>

            @if (gs('promotional_tool') && $promotionCount)
                <li class="sidebar-menu-list__item {{ menuActive('user.promotional.banner') }}">
                    <a href="{{ route('user.promotional.banner') }}" class="sidebar-menu-list__link">
                        <span class="icon"> <i class="fa-solid fa-ad"></i> </span>
                        <span class="text">@lang('Promotional Tool')</span>
                    </a>
                </li>
            @endif

            <li 
                class="sidebar-menu-list__item has-dropdown 
                {{ menuActive([
                    'user.profile.setting',
                    'user.change.password',
                    'user.invest.ranking',
                    'user.twofactor',
                    'ticket.index',
                    'ticket.open',
                    'ticket.view',
                ]) }}"
            >
                <a href="javascript:void(0)" class="sidebar-menu-list__link">
                    <span class="icon"><i class="fas fa-user"></i></span>
                    <span class="text"> @lang('Account') </span>
                </a>
                <div class="sidebar-submenu">
                    <ul class="sidebar-submenu-list">
                        <li class="sidebar-submenu-list__item {{ menuActive('user.profile.setting') }}">
                            <a href="{{ route('user.profile.setting') }}" class="sidebar-submenu-list__link">@lang('Profile Setting')</a>
                        </li>
                        <li class="sidebar-submenu-list__item {{ menuActive('user.change.password') }}">
                            <a href="{{ route('user.change.password') }}" class="sidebar-submenu-list__link">@lang('Change Password')</a>
                        </li>
                        @if (gs('user_ranking'))
                            <li class="sidebar-submenu-list__item {{ menuActive('user.invest.ranking') }}">
                                <a href="{{ route('user.invest.ranking') }}" class="sidebar-submenu-list__link">@lang('Ranking')</a>
                            </li>
                        @endif
                        <li class="sidebar-submenu-list__item {{ menuActive('user.twofactor') }}">
                            <a href="{{ route('user.twofactor') }}" class="sidebar-submenu-list__link">@lang('2FA Security')</a>
                        </li>
                        <li class="sidebar-submenu-list__item {{ menuActive('ticket.index') }}">
                            <a href="{{ route('ticket.index') }}" class="sidebar-submenu-list__link">@lang('Support Ticket')</a>
                        </li>
                    </ul>
                </div>
            </li>

            <li class="sidebar-menu-list__item">
                <a href="{{ route('user.logout') }}" class="sidebar-menu-list__link logout">
                    <span class="icon"><i class="fas fa-sign-out-alt"></i></span>
                    <span class="text">@lang('Logout')</span>
                </a>
            </li>
        </ul>
        <!-- ========= Sidebar Menu End ================ -->
    </div>
</div>
<!-- ====================== Sidebar menu End ========================= -->