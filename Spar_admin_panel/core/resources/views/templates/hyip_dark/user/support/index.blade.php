@extends($activeTemplate . 'layouts.master')

@section('content')
    <div class="row gy-4">
        <div class="col-md-12">
            <div class="text-end">
                <a href="{{ route('ticket.open') }}" class="btn btn--base btn--lg">@lang('Open Support Ticket')</a>
            </div>
        </div>
        <div class="col-md-12">
            <div class="card custom--card">
                <div class="card-body">
                    <table class="table table--responsive--xl">
                        <thead>
                            <tr>
                                <th>@lang('Subject')</th>
                                <th>@lang('Status')</th>
                                <th>@lang('Priority')</th>
                                <th>@lang('Last Reply')</th>
                                <th>@lang('Action')</th>
                            </tr>
                        </thead>
                        <tbody>
                            @forelse($supports as $support)
                                <tr>
                                    <td> <a href="{{ route('ticket.view', $support->ticket) }}" class="fw-bold"> [@lang('Ticket')#{{ $support->ticket }}] {{ __($support->subject) }} </a></td>
                                    <td>
                                        @php echo $support->statusBadge; @endphp
                                    </td>
                                    <td>
                                        @if ($support->priority == 1)
                                            <span class="badge badge--dark">@lang('Low')</span>
                                        @elseif($support->priority == 2)
                                            <span class="badge badge--success">@lang('Medium')</span>
                                        @elseif($support->priority == 3)
                                            <span class="badge badge--primary">@lang('High')</span>
                                        @endif
                                    </td>
                                    <td>{{ diffForHumans($support->last_reply) }} </td>

                                    <td>
                                        <div class="action--btns">
                                            <a href="{{ route('ticket.view', $support->ticket) }}" class="icon-btn bg--base text-white">
                                                <i class="fa fa-desktop"></i>
                                            </a>
                                        </div>
                                    </td>
                                </tr>
                            @empty
                                <tr>
                                    <td colspan="100%" class="text-center">{{ __($emptyMessage) }}</td>
                                </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>
            </div>
            {{ paginateLinks($supports) }}
        </div>
    </div>
@endsection

@push('style')
    <style>
        .badge--dark {
            color: #999;
            border-color: #999;
            background-color: rgba(153, 153, 153, 0.15);
        }
    </style>
@endpush
