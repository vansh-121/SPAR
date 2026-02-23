<ul class="nav nav-tabs mb-4 topTap breadcrumb-nav" role="tablist">
    <button class="breadcrumb-nav-close"><i class="las la-times"></i></button>
    <li class="nav-item {{ menuActive('admin.time.index') }}" role="presentation">
        <a href="{{ route('admin.time.index') }}" class="nav-link text-dark" type="button">
            <i class="las la-clock"></i> @lang('Time Setting')
        </a>
    </li>
    <li class="nav-item {{ menuActive('admin.plan.index') }}" role="presentation">
        <a href="{{ route('admin.plan.index') }}" class="nav-link text-dark" type="button">
            <i class="las la-list"></i> @lang('Manage Plan')
        </a>
    </li>
</ul>
