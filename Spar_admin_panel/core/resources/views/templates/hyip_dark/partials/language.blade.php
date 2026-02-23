@php
    $language = App\Models\Language::all();
    $selectLang = $language->where('code', config('app.locale'))->first();
    $currentLang = session('lang') ? $language->where('code', session('lang'))->first() : $language->where('is_default', Status::YES)->first();
@endphp

<div class="dropdown lang-box">
    <button class="lang-box-btn" data-bs-toggle="dropdown">
        <span class="thumb">
            <img class="fit-image" src="{{ getImage(getFilePath('language') . '/' . @$currentLang->image, getFileSize('language')) }}" alt="@lang('image')">
        </span>
        <span class="text">{{ __(@$selectLang->name) }}</span>
        <span class="icon">
            <i class="fas fa-angle-down"></i>
        </span>
    </button>
    <ul class="dropdown-menu">
        @foreach ($language as $item)
            <li class="lang-box-item @if(session('lang') == $item->code) selected @endif" data-value="{{ $item->code }}">
                <a href="{{ route('lang', $item->code) }}" class="lang-box-link">
                    <div class="thumb">
                        <img class="fit-image" src="{{ getImage(getFilePath('language') . '/' . @$item->image, getFileSize('language')) }}" alt="@lang('image')">
                    </div>
                    <span class="text">{{ __($item->name) }}</span>
                </a>
            </li>
        @endforeach
    </ul>
</div>
